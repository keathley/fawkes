defmodule Fawkes.Listener do
  defmacro __using__(_opts) do
    quote do
      Module.register_attribute(__MODULE__, :listeners, accumulate: true)

      import unquote(__MODULE__)
      import Fawkes.Bot, only: [reply: 2, say: 2, code: 2]

      @before_compile unquote(__MODULE__)

      @behaviour Fawkes.EventHandler

      def init(_bot, state) do
        {:ok, state}
      end

      defoverridable init: 2
    end
  end

  defmacro __before_compile__(%{module: module}) do
    listeners = Module.get_attribute(module, :listeners)

    ast = compile_listeners(listeners)

    help_msg =
      listeners
      |> Enum.map(& &1.help)
      |> Enum.join()

    quote do
      @doc false
      def help do
        unquote(help_msg)
      end

      unquote(ast)
    end
  end

  @doc """
  Defines a listener that will "hear" any matching regex and call the
  provided callback function.
  """
  defmacro hear(regex, f) do
    f = Macro.escape(f)
    regex = Macro.escape(regex)

    quote do
      help = Module.get_attribute(__MODULE__, :help)
      Module.delete_attribute(__MODULE__, :help)
      @listeners %{type: :hear, matcher: unquote(regex), f: unquote(f), help: help}
    end
  end

  @doc """
  Defines a listener that will only trigger if the bot was mentioned and
  the regex pattern is matched. Respond assumes that the message mentions the
  bot as the first part of text.
  """
  defmacro respond(regex, f) do
    f = Macro.escape(f)
    regex = Macro.escape(regex)

    quote do
      help = Module.get_attribute(__MODULE__, :help)
      Module.delete_attribute(__MODULE__, :help)
      @listeners %{type: :respond, matcher: unquote(regex), f: unquote(f), help: help}
    end
  end

  @doc """
  Defines a generic listener. This listener receives all events and passes them
  to the matcher function. If the matcher function returns a truthy value then the second
  callback will be executed with the value passed as the first argument and the event
  as the second. If the matcher returns false then the callback will be skipped.
  If you need to return a falsey value from your matcher you will need to wrap it
  in another value such as a tuple or a map.

  The callback can either be a 2 arity or 3 arity function with the optional 3rd
  argument being the current state for the handler.
  """
  defmacro listen(matcher, f) do
    matcher = Macro.escape(matcher)
    f       = Macro.escape(f)

    quote do
      help = Module.get_attribute(__MODULE__, :help)
      Module.delete_attribute(__MODULE__, :help)
      @listeners %{type: :listen, matcher: unquote(matcher), f: unquote(f), help: help}
    end
  end

  defp compile_listeners(listeners) do
    listeners =
      listeners
      |> Enum.map(&compile_listener/1)

    quote do
      @doc false
      def handle_event(event, state) do
        Enum.reduce(unquote(listeners), state, fn {m, f, as}, state ->
          apply(m, f, [event, state] ++ as)
        end)
      end
    end
  end

  defp compile_listener(l) do
    quote do
      {Fawkes.Bot, unquote(l.type), [unquote(l.matcher), unquote(l.f)]}
    end
  end
end
