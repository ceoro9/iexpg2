defmodule Pg2.GroupInstance do
  use Supervisor

  @process_name_suffix "instance_"

  def start_link(group_name) do
    Supervisor.start_link(
      __MODULE__,
      group_name,
      name: get_process_name(group_name)
    )
  end

  def init(_) do
    Supervisor.init([Pg2.GroupRunner], strategy: :one_for_one)
  end

  def get_process_name([group_name]) do
    (@process_name_suffix <> group_name) |> String.to_atom()
  end
end
