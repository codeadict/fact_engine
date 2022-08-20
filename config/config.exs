import Config

config :logger, handle_sasl_reports: true

config :logger, :console,
  format: "$time $metadata[$level] $levelpad$message\n",
  level: :warn

if config_env() == :prod do
  config :logger, :console, level: :error
end
