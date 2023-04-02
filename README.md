## Niner 
> "Go West, young man" - Horace Greeley

- The overall goal is to build a scalable, robust, cryptocurrency trading bot capable of profiting per-trade with transaction costs included.

- Project summary:
	- train [DRL trading agents](https://en.wikipedia.org/wiki/Reinforcement_learning) on historical and real-time cryptocurrency market data (BTC-USD, ETH-USD, etc.)
	- DRL agents use the following environment parameters for the assets of interest:
		- price (done)
		- market capitalization (in progress)
		- trading volume (in progress)
		- network hash rate (in progress)
		- difficulty (in progress)
	- train the DRL trading agents using the following algorithms:
		- [A2C](https://arxiv.org/abs/1602.01783)
		- [DDPG](https://arxiv.org/abs/1509.02971)
		- [PPO](https://arxiv.org/abs/1707.06347)
		- [Ensemble strategy](https://en.wikipedia.org/wiki/Ensemble_learning) in coordination with [Sharpe ratio](https://web.stanford.edu/~wfsharpe/art/sr/sr.htm)
	- make trade decisions (buy/sell) based on predicted price of the assets,
	- (goal) gain cumulative return over 12+ months, barring global chaos :)


## Disclaimer
- This is an unfinished side project that I maintain in my free time, don't use it in production environments.


## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `niner` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:niner, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/niner](https://hexdocs.pm/niner).

