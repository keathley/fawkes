defmodule Fawkes.Script do
  defmacro __using__(_opts) do
    quote do
      @before_compile unquote(__MODULE__)

      Module.register_attribute(__MODULE__, :listeners, accumulate: true)

      import unquote(__MODULE__), only: [hear: 2, respond: 2]
    end
  end

  defmacro __before_compile__(%{module: module}) do
    listeners = Module.get_attribute(module, :listeners)

    quote location: :keep do
      def listeners do
        unquote(listeners)
      end
    end
  end

  defmacro hear(regex, func) do
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

  def build(type, regex, func) do
    # func = Macro.escape(func)

    quote do
      help = Module.get_attribute(__MODULE__, :help)
      Module.delete_attribute(__MODULE__, :help)

      %{
        type: unquote(type),
        regex: unquote(regex),
        func: f,
        help: help
      }
    end
  end
end
