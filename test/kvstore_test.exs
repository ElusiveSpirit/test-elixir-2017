defmodule KVstoreTest do
  use ExUnit.Case, async: false

  setup do
    KVstore.Storage.clear
    KVstore.Storage.put("new", 1)
    :ok
  end

  test "Main storage test" do
    assert {:ok, "new", 1} == KVstore.Storage.get("new")
  end

  test "Save dump to file" do
    GenServer.stop(KVstore.Storage)

    assert File.exists? "tmp/dump_file.json"
    assert File.read!("tmp/dump_file.json") == ~s({"new":{"value":1}})
  end

  test "restore data after stop" do
    KVstore.Storage.put("one_more", "hello")

    GenServer.stop(KVstore.Storage)

    :timer.sleep(100)
    assert {:ok, "new", 1} == KVstore.Storage.get("new")
    assert {:ok, "one_more", "hello"} == KVstore.Storage.get("one_more")
  end

  test "value expire in 1 sec" do
    KVstore.Storage.put("time", "Time is running", 1)

    :timer.sleep(1100)

    assert {:error, :expired} == KVstore.Storage.get("time")
  end

  test "Get access to expires value" do
    KVstore.Storage.put("time", "Time is running", 100)

    assert {:ok, "time", "Time is running"} == KVstore.Storage.get("time")
  end

  test "No value" do
    assert {:error, :not_exists} == KVstore.Storage.get("no key")
  end
end
