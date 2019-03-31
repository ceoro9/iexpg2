defmodule Pg2.GroupRunner do
  use GenServer

  def start_link(default) do
    # TODO: may be add name
    GenServer.start_link(__MODULE__, default)
  end

  @impl true
  def init(_) do
    {:ok, %{}}
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

  defp do_handle_call(_message) do
    # TODO:
    # iterate over running processes and put message to their mailbox
    {:ok}
  end
end
