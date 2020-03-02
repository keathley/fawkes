defmodule Fawkes.Listener do
  defmacro __using__(_opts) do
    quote do
      Module.register_attribute(__MODULE__, :listeners, accumulate: true)

      import unquote(__MODULE__)
      import Fawkes.Bot, only: [reply: 2, say: 2, code: 2]

      @before_compile unquote(__MODULE__)
      @behaviour Fawkes.EventHandler
    end
  end

  defmacro __before_compile__(%{module: module}) do
    listeners = Module.get_attribute(module, :listeners)

    ast = compile_listeners(listeners)

    quote do
      def init(state) do
        {:ok, state}
      end

      unquote(ast)

      defoverridable init: 1
    end
  end

  defmacro hear(regex, f) do
    f = Macro.escape(f)
    regex = Macro.escape(regex)

    quote do
      @listeners %{type: :hear, regex: unquote(regex), f: unquote(f)}
    end
  end

  defmacro respond(regex, f) do
    f = Macro.escape(f)
    regex = Macro.escape(regex)

    quote do
      @listeners %{type: :respond, regex: unquote(regex), f: unquote(f)}
    end
  end

  defp compile_listeners(listeners) do
    listeners =
      listeners
      |> Enum.map(&compile_listener/1)

    quote do
      def handle_event(event, state) do
        Enum.reduce(unquote(listeners), state, fn {m, f, as}, state ->
          apply(m, f, [event, state] ++ as)
        end)
      end
    end
  end

  defp compile_listener(l) do
    quote do
      {Fawkes.Bot, unquote(l.type), [unquote(l.regex), unquote(l.f)]}
    end
  end
end
