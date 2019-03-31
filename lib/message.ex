defmodule Pg2.Message do
  defstruct id: nil,
            timestamp: nil,
            ttl: nil,
            initial_node: nil,
            content: nil

  def new(content, ttl \\ 5000) do
    %Pg2.Message{
      id: UUID.uuid4(),
      timestamp: DateTime.utc_now(),
      ttl: ttl,
      initial_node: Node.self(),
      content: content
    }
  end
end
