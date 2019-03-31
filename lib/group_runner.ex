defmodule Pg2.GroupRunner do
  use GenServer

  @process_name_suffix "instance_"

  def start_link([group_name | _]) do
    GenServer.start_link(__MODULE__, [], name: get_process_name(group_name))
  end

  @impl true
  def init(_) do
    {:ok, %{}}
  end

  defp get_process_name(group_name) do
    (@process_name_suffix <> group_name) |> String.to_atom()
  end

  @impl true
  def handle_call({:call, message}, _from, state) do
    # TODO: use task to make the job and wait
    do_handle_call(message)
    {:reply, :ok, state}
  end

  @impl true
  def handle_cast({:call, message}, state) do
    # TODO: use task to make the job and do not wait
    do_handle_call(message)
    {:noreply, state}
  end

  defp do_handle_call(message) do
    # TODO:
    # iterate over running processes and put message to their mailbox
    IO.puts("got new message: ")
    IO.inspect(message)
    {:ok}
  end

  def send_message(group_name, message) do
    # pass message to all runners in cluster
    GenServer.multi_call(
      Node.list([:this, :visible]),
      get_process_name(group_name),
      {:call, message}
    )
  end
end
