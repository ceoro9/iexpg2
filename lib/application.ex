defmodule Pg2.Application do
  use Application

  def start(_, _) do
    Pg2.TopSupervisor.start_link()
  end
end
