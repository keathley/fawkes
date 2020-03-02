defmodule Fawkes.Brain do
  @moduledoc """
  Provides an interface for persistent storage. Adapters are expected to
  accept any term and manage serialization and deserialization.
  """

  @callback start_link(Keyword.t()) :: term()
  @callback get(atom(), String.t(), term()) :: term()
  @callback set(atom(), String.t(), term()) :: term()
end
