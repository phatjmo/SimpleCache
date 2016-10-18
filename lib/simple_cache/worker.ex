defmodule SimpleCache.Worker do
  use GenServer

  @name SC

# Client
  def start_link(opts \\ [] ) do
    GenServer.start_link(__MODULE__, :ok, opts ++ [name: SC])
  end

  def write(bucket, value) do
    GenServer.cast(@name, {:write, bucket, value})
  end

  def read(bucket) do
    GenServer.call(@name, {:read, bucket})
  end

  def delete(bucket) do
    GenServer.cast(@name, {:delete, bucket})
  end
  
  def clear do
    GenServer.cast(@name, :clear)
  end

  def exist(bucket) do
    GenServer.call(@name, {:exist, bucket})
  end

  def stop do
    GenServer.cast(@name, :stop)
  end

  def terminate(reason, cache) do
    IO.puts "SimpleCache terminated because of #{inspect reason}"
      inspect cache
  end

  # Server

    def init(:ok) do
    {:ok, %{}}
  end

  # Handle Calls

  def handle_call({:read, bucket}, _from, cache) do
    case Map.has_key?(cache, bucket) do
      true ->
        value = Map.get(cache, bucket)
        {:reply, value, cache}
      false ->
        {:reply, :error, cache}
      _ ->
        {:reply, :error, cache}
    end
  end

  def handle_call({:exist, bucket}, _from, cache) do
    case Map.has_key?(cache, bucket) do
      true ->
        {:reply, true, cache}
      false ->
        {:reply, false, cache}
      _ ->
        {:reply, :error, cache}
    end
  end

  # Handle Casts

  def handle_cast({:write, bucket, value}, cache) do
    new_cache = update_cache(cache, bucket, value)
    {:noreply, new_cache}   
  end

  def handle_cast({:delete, bucket}, cache) do
    new_cache = Map.delete(cache, bucket)
    {:noreply, new_cache}
  end

  def handle_cast(:clear, _cache) do
    {:noreply, %{}}
  end

  def handle_cast(:stop, cache) do
    {:stop, :normal, cache}
  end

  # Handle Other Messages
  def handle_info(msg, cache) do
    IO.puts "Received #{inspect msg}"
    {:noreply, cache}
  end

  # Helper Functions

  defp update_cache(old_cache, bucket, value) do
    case Map.has_key?(old_cache, bucket) do
      true ->
        Map.update!(old_cache, bucket, value)
      false ->
        Map.put_new(old_cache, bucket, value)
    end
  end

end