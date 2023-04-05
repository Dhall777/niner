import Config

config :niner, Niner.Repo,
  ecto_repos: [Niner.Repo],
  database: "niner_dev",
  username: "darri",
  password: "r$pJcntR24Qq*54bAlGsQLQ%3uoOVgJk",
  hostname: "localhost",
  show_sensitive_data_on_connection_error: true,
  pool_size: 10

config :nx, default_backend: EXLA.Backend
