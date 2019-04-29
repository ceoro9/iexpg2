defmodule Pg2.TopSupervisor do
  use DynamicSupervisor

  def start_link do
    DynamicSupervisor.start_link(
      __MODULE__,
      [],
      name: __MODULE__
    )
  end

  def start_new_group(group_name) do
    Node.list([:visible])
    |> Enum.map(fn node ->
        :rpc.call(
          node,
          Pg2.TopSupervisor,
          :local_start_new_group,
          [group_name]
        )
    end)
    |> IO.inspect
    local_start_new_group(group_name)
  end

  def local_start_new_group(group_name) do
    IO.inspect("starting group: #{group_name} on #{Node.self()}")
    DynamicSupervisor.start_child(__MODULE__, {Pg2.GroupInstance, [group_name]})
  end

  @impl true
  def init(_) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end
end
