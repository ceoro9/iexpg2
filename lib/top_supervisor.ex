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
    DynamicSupervisor.start_child(__MODULE__, {Pg2.GroupInstance, [group_name]})
  end

  @impl true
  def init(_) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end
end
