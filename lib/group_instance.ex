defmodule Pg2.GroupInstance do
  use Supervisor

  def start_link([group_name | _]) do
    Supervisor.start_link(
      __MODULE__,
      group_name
      # TODO: give name to terminate.
    )
  end

  def init(group_name) do
    Supervisor.init([{Pg2.GroupRunner, [group_name]}], strategy: :one_for_one)
  end
end
