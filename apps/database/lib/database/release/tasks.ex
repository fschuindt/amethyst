defmodule DataBase.Release.Tasks do
  # See:
  # https://hexdocs.pm/distillery/running-migrations.html

  @moduledoc false

  @start_apps [
    :crypto,
    :ssl,
    :postgrex,
    :ecto
  ]

  def database, do: :database

  def repos, do: Application.get_env(database(), :ecto_repos, [])

  def seed do
    migrate()

    Enum.each(repos(), &run_seeds_for/1)

    IO.puts("Success!")
    :init.stop()
  end

  defp prepare do
    me = database()

    IO.puts("Loading #{me}..")
    :ok = Application.load(me)

    IO.puts("Starting dependencies..")
    Enum.each(@start_apps, &Application.ensure_all_started/1)

    IO.puts("Starting repos..")
    Enum.each(repos(), & &1.start_link(pool_size: 1))
  end

  def migrate do
    prepare()
    Enum.each(repos(), &run_migrations_for/1)
  end

  def priv_dir(app), do: "#{:code.priv_dir(app)}"

  defp run_migrations_for(repo) do
    app = Keyword.get(repo.config, :otp_app)
    IO.puts("Running migrations for #{app}")
    Ecto.Migrator.run(repo, migrations_path(repo), :up, all: true)
  end

  def run_seeds_for(repo) do
    seed_script = seeds_path(repo)

    if File.exists?(seed_script) do
      IO.puts("Running seed script..")
      Code.eval_file(seed_script)
    end
  end

  def migrations_path(repo), do: priv_path_for(repo, "migrations")

  def seeds_path(repo), do: priv_path_for(repo, "seeds.exs")

  def priv_path_for(repo, filename) do
    app = Keyword.get(repo.config, :otp_app)
    repo_underscore = repo |> Module.split() |> List.last() |> Macro.underscore()
    Path.join([priv_dir(app), repo_underscore, filename])
  end
end
