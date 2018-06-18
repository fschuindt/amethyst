# API

A set of examples to interact with the GraphQL API.

## Account Opening

This endpoint provides the ability to open a new bank account.

It will give you the required credentials to later perform authorization (`id` and `apiToken`). Be sure to save them.

*If you try to open a new account sending valid authorization headers it will prevent you to proceed.*

**Input:**
```graphql
mutation OpenAccount {
  openAccount(name: "Jon Lord") {
    id
    name
    apiToken
  }
}

```

**Output:**
```json
{
  "data": {
    "openAccount": {
      "name": "Jon Lord",
      "id": "108",
      "apiToken": "kmULONLCtLZCmwf0DBkNcFE3sRiGdAeKLJ1vCgTIcNf79KV0n2U"
    }
  }
}
```

## Authorization

From this point, all interactions will flag **Requires Authorization**, that means in order to proceed you shall provide authorization headers within the connection request.

Be sure to provide the following headers:

| Key          | Value                    |
|--------------|--------------------------|
| `account-id` | Your account `id`.       |
| `api-token`  | Your account `apiToken`. |

## Assets Transfer

**Requires Authorization**

Allows you to transfer assets from the current authorized account to another registered account by passing its `id`.

**Input:**
```graphql
mutation AssetsTransfer {
  assetsTransfer(recipientAccountId: 102, amount: 200) {
    id
    amount
    transferAt
    senderAccountId
    recipientAccountId
  }
}
```

**Output:**
```json
{
  "data": {
    "assetsTransfer": {
      "transferAt": "2018-06-12T13:39:03.769877Z",
      "senderAccountId": "109",
      "recipientAccountId": "102",
      "id": "11",
      "amount": "200"
    }
  }
}
```

## Assets Withdraw
**Requires Authorization**

**Input:**
```graphql
mutation AssetsWithdraw {
  assetsWithdraw(amount: 100.99) {
    id
    accountId
    amount
    direction
    initialBalance
    finalBalance
    moveAt
    moveOn
  }
}
```

**Output:**
```json
{
  "data": {
    "assetsWithdraw": {
      "moveOn": "2018-06-12",
      "moveAt": "2018-06-12T13:54:12.131650Z",
      "initialBalance": "699.0100",
      "id": "152",
      "finalBalance": "598.0200",
      "direction": -1,
      "amount": "100.99",
      "accountId": "109"
    }
  }
}
```

## Current Report
**Requires Authorization**

**Input:**
```graphql
{
  dateReport {
    date
    initialBalance
    finalBalance
    inbounds
    outbounds
  }
}
```

**Output:**
```json
{
  "data": {
    "dateReport": {
      "outbounds": "401.9800",
      "initialBalance": "0.0000",
      "inbounds": "1000.0000",
      "finalBalance": "598.0200",
      "date": "2018-06-12",
      "accountId": "109"
    }
  }
}
```

## Date Report
**Requires Authorization**

**Input:**
```graphql
{
  dateReport(date: "2018-06-12") {
    date
    initialBalance
    finalBalance
    inbounds
    outbounds
  }
}
```

**Output:**
```json
{
  "data": {
    "dateReport": {
      "outbounds": "401.9800",
      "initialBalance": "0.0000",
      "inbounds": "1000.0000",
      "finalBalance": "598.0200",
      "date": "2018-06-12",
      "accountId": "109"
    }
  }
}
```

## Month Report
**Requires Authorization**

**Input:**
```graphql
{
  monthReport(month: 6, year: 2018) {
    initialBalance
    finalBalance
    inbounds
    outbounds
  }
}
```

**Output:**
```json
{
  "data": {
    "monthReport": {
      "outbounds": "401.9800",
      "initialBalance": "0.0000",
      "inbounds": "1000.0000",
      "finalBalance": "598.0200"
    }
  }
}
```

## Year Report
**Requires Authorization**

**Input:**
```graphql
{
  yearReport(year: 2018) {
    initialBalance
    finalBalance
    inbounds
    outbounds
  }
}
```

**Output:**
```json
{
  "data": {
    "yearReport": {
      "outbounds": "401.9800",
      "initialBalance": "0.0000",
      "inbounds": "1000.0000",
      "finalBalance": "598.0200"
    }
  }
}
```

## Period Report
**Requires Authorization**

**Input:**
```graphql
{
  periodReport(from: "2018-06-05", to: "2018-06-12") {
    initialBalance
    finalBalance
    inbounds
    outbounds
  }
}
```

**Output:**
```json
{
  "data": {
    "periodReport": {
      "outbounds": "401.9800",
      "initialBalance": "0.0000",
      "inbounds": "1000.0000",
      "finalBalance": "598.0200"
    }
  }
}
```

## Overall Report
**Requires Authorization**

**Input:**
```graphql
{
  report {
    initialBalance
    finalBalance
    inbounds
    outbounds
  }
}
```

**Output:**
```json
{
  "data": {
    "report": {
      "outbounds": "401.9800",
      "initialBalance": "0.0000",
      "inbounds": "1000.0000",
      "finalBalance": "598.0200"
    }
  }
}
```

