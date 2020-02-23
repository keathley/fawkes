defmodule Fawkes.Script do
  defmacro __using__(_opts) do
    quote do
      @before_compile unquote(__MODULE__)

      Module.register_attribute(__MODULE__, :listeners, accumulate: true)

      import unquote(__MODULE__)
    end
  end

  defmacro __before_compile__(%{module: module}) do
    listeners = Module.get_attribute(module, :listeners)

    compiled =
      listeners
      |> Enum.map(fn listener -> compile_listener(listener) end)

    list =
      listeners
      |> Enum.map(fn l -> Map.drop(l, [:func]) end)
      |> Macro.escape()

    quote location: :keep do
      unquote(compiled)

      def listeners do
        Enum.map(unquote(list), fn l ->
          f = fn msg ->
            dispatch(l.type, l.name, msg)
          end
          Map.put(l, :func, f)
        end)
      end
    end
  end

  defmacro hear(regex, func) do
    matcher = fn msg ->
      Regex.match?(regex, msg.text)
    end
    listener = build(:hear, regex, func)

    quote do
      @listeners unquote(listener)
    end
  end

  defmacro respond(regex, func) do
    listener = build(:respond, regex, func)

    quote do
      @listeners unquote(listener)
    end
  end

  def say(msg, text) when is_binary(text) do
    send(msg.bot, {:say, msg, text})
  end

  def reply(msg, text) when is_binary(text) do
    send(msg.bot, {:reply, msg, text})
  end

  def emote(msg, text) when is_binary(text) do
    send(msg.bot, {:emote, msg, text})
  end

  defp build(type, regex, func) do
    func = Macro.escape(func)

    quote bind_quoted: [type: type, regex: regex, func: func] do
      help = Module.get_attribute(__MODULE__, :help)
      Module.delete_attribute(__MODULE__, :help)

      %{
        name: Regex.source(regex),
        type: type,
        regex: regex,
        func: func,
        help: help
      }
    end
  end

  defp compile_listener(command) do
    quote do
      def dispatch(unquote(command.type), unquote(command.name), msg) do
        unquote(command.func).(msg)
      end
    end
  end
end
