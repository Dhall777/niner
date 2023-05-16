## Niner 
> "Go West, young man" - Horace Greeley

- The overall goal is to build a scalable, robust, cryptocurrency trading bot capable of profiting per-trade (with transaction costs included)

- Project overview:
	- train DNN model on historical market data (BTC-USD, ETH-USD, etc.)
	- features of the historical market data (and thus, the number of input layer units/neurons):
		- date
		- open
		- high
		- low
		- close
		- adjusted close
		- volume
	- the model's hidden layers primarily utilize the [LSTM](https://en.wikipedia.org/wiki/Long_short-term_memory) architecture, which is extremely useful for sequential data processing 
	- the overall DNN model uses the following loss function(s) to improve prediction accuracy:
		- [MSE](https://en.wikipedia.org/wiki/Mean_squared_error)
		- [A3C](https://en.wikipedia.org/wiki/Reinforcement_learning)
	- predict market prices based on real-time market data input
	- make various trade decisions (buy/sell/hold) based on the predicted price
	- goal: make 70% successful trades based on predictions of real-time market prices, barring global chaos :)



## Disclaimer
- This is an active side project that I maintain in my free time, don't use it in production environments.



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

