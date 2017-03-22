defmodule KVstore.Storage do
  use GenServer

  ## Client API

  def start_link do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  @doc """
  Returns `{:ok, key, value}` if the value exists, `{:error, reason}` otherwise.
  """
  def get(key) do
    GenServer.call(__MODULE__, {:get, key})
  end

  def get!(key) do
    case GenServer.call(__MODULE__, {:get, key}) do
      {:ok, _key, value} -> value
      {:error, _} -> nil
    end
  end

  @doc """
  Returns all values
  """
  def get_all do
    GenServer.call(__MODULE__, :get_all)
  end

  @doc """
  Puts value by key
  """
  def put(key, value, ttl \\ 0) when is_integer(ttl) do
    if ttl > 0 do
      GenServer.cast(__MODULE__, {:put, key, %{"value" => value, "ttl" => :os.system_time(:seconds) + ttl}})
    else
      GenServer.cast(__MODULE__, {:put, key, %{"value" => value}})
    end
  end

  def put(_, _, _), do: {:error, "ttl must be integer"}


  @doc """
  Removes value by key
  """
  def delete(key) do
    GenServer.cast(__MODULE__, {:delete, key})
  end

  @doc """
  Clear all dict
  """
  def clear do
    GenServer.cast(__MODULE__, :clear)
  end

  ## Server Callbacks

  def init(:ok) do
    {:ok, KVstore.Utils.load_state}
  end

  def handle_call(:get_all, _from, map) do
    {:reply, map, map}
  end

  def handle_call({:get, key}, _from, map) do
    reply =
      case Map.fetch(map, key) do
        {:ok, %{"value" => value, "ttl" =>  ttl}} ->
          if ttl > :os.system_time(:seconds) do
            {:ok, key, value}
          else
            map = Map.delete(map, key)
            {:error, :expired}
          end
        {:ok, %{"value" => value}} ->
          {:ok, key, value}
        :error ->
          {:error, :not_exists}
      end
    {:reply, reply, map}
  end

  def handle_cast({:put, key, value}, map) do
    {:noreply, Map.put(map, key, value)}
  end

  def handle_cast({:delete, key}, map) do
    {:noreply, Map.delete(map, key)}
  end

  def handle_cast(:clear, _map) do
    {:noreply, %{}}
  end

  def terminate(_reason, state) do
    KVstore.Utils.dump_state state
  end
end
