## Niner 
> "Go West, young man" - Horace Greeley

- Project overview:
	- train deep nueral network (DNN) model on historical cryptocurrency market data (BTC-USD, ETH-USD, etc.)
	- features of the historical market data:
		- date
		- close (i.e., closing price of crypto product of choice)
	- the model's hidden layers primarily utilize the [LSTM](https://en.wikipedia.org/wiki/Long_short-term_memory) architecture
	- the DNN model's training process uses the following loss function(s):
		- [MSE](https://en.wikipedia.org/wiki/Mean_squared_error) -> temporary
		- [A3C](https://en.wikipedia.org/wiki/Reinforcement_learning) -> weird, custom loss function not implemented yet
	- predict crypto prices given market data input (i.e., x_test)
		- x_test is fed to the model manually for now, but will eventually pull from our internal DB of realtime prices
	- make various trade decisions (buy/sell/hold) based on the confidence internal of our prediction
	- make 95% successful trade predictions, barring global chaos



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

