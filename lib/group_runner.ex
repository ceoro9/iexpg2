defmodule Pg2.GroupRunner do
  use GenServer

  @process_name_suffix "instance_"

  def start_link([group_name | _]) do
    GenServer.start_link(__MODULE__, [group_name], name: get_process_name(group_name))
  end

  @impl true
  def init(group_name) do
    {:ok,
     %{
       group_name: group_name,
       processes: []
     }}
  end

  defp get_process_name(group_name) do
    (@process_name_suffix <> group_name) |> String.to_atom()
  end

  @impl true
  def handle_call({:call, message}, _from, state) do
    # TODO: use task to make the job and wait
    do_handle_call(message, state)
    {:reply, :ok, state}
  end

  @impl true
  def handle_call({:add_process, pid}, _from, state) do
    case Process.alive?(pid) do
      true ->
        ref = Process.monitor(pid)

        if handle_process_in_group?(pid, state) do
          {:reply, {:error, "Process is already in group"}, state}
        else
          {:reply, :ok, %{state | processes: [{ref, pid} | state.processes]}}
        end

      false ->
        {:reply, {:error, "Process is dead"}, state}
    end
  end

  def handle_call(:list_processes, _from, state) do
    {:reply, Enum.map(state.processes, fn {_, pid} -> pid end), state}
  end

  def handle_call({:in_group?, searched_process_pid}, _from, state) do
    {:reply, process_in_group?(searched_process_pid, state), state}
  end

  defp handle_process_in_group?(searched_process_pid, state) do
    state.processes
    |> Enum.map(fn {_, pid} -> pid end)
    |> Enum.member?(searched_process_pid)
  end

  @impl true
  def handle_cast({:call, message}, state) do
    # TODO: use task to make the job and do not wait
    do_handle_call(message, state)
    {:noreply, state}
  end

  @impl true
  def handle_info({:DOWN, monitor_ref, :process, _from_pid, _exit_reason}, state) do
    IO.puts("exit process")

    {:noreply,
     %{state | processes: Enum.filter(state.processes, fn {ref, _} -> ref != monitor_ref end)}}
  end

  defp do_handle_call(message, state) do
    # iterate over running processes and put message to their mailbox
    state.processes
    |> Enum.map(fn {_, pid} -> pid end)
    |> Enum.each(fn pid -> send(pid, message) end)

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

  def add_process(group_name, process_pid) do
    GenServer.call(get_process_name(group_name), {:add_process, process_pid})
  end

  def list_current_running_processes(group_name) do
    GenServer.call(get_process_name(group_name), :list_processes)
  end

  def group_exists?(group_name) do
    case get_process_name(group_name) |> Process.whereis() do
      nil -> false
      _ -> true
    end
  end

  def process_in_group?(group_name, pid) do
    GenServer.call(get_process_name(group_name), {:in_group?, pid})
  end
end
