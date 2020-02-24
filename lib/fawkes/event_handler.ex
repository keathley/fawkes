defmodule Fawkes.EventHandler do
  @moduledoc """
  Defines a behaviour for building event handlers.
  """

  alias Fawkes.Event

  @callback init(term()) :: {:ok, term()}
  @callback handle_event(Event.t, term()) :: {:ok, term()}
end
