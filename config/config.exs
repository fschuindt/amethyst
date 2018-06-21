use Mix.Config

# Import Umbrella apps configs
import_config "../apps/*/config/config.exs"

# Import global environment config
import_config "#{Mix.env}.exs"
