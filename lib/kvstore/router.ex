defmodule KVstore.Router do
  use Plug.Router

  plug Plug.Parsers,
    parsers: [:urlencoded, :json],
    pass:  ["text/*"],
    json_decoder: Poison

  plug :match
  plug :dispatch

  # get one
  get "/storage/:key/" do
    resp =
      case key |> KVstore.Storage.get do
        {:ok, _key, value} -> value
        {:error, error} -> error
      end
      |> Poison.encode!

    send_resp(conn, 200, resp)
  end

  # delete
  delete "/storage/:key/" do
    KVstore.Storage.delete key

    send_resp(conn, 200, Poison.encode!(%{key: key, status: "deleted"}))
  end

  # update
  put "/storage/:key/" do
    case conn.body_params do
      %{"value"  => value, "ttl" => ttl} ->
        KVstore.Storage.put(key, value, ttl)
        send_resp(conn, 200, Poison.encode!(%{msg: "OK. Will expire in #{ttl}"}))
      %{"value"  => value} ->
        KVstore.Storage.put(key, value)
        send_resp(conn, 200, Poison.encode!(%{msg: "OK"}))
      _ ->
        send_resp(conn, 200, Poison.encode!(%{msg: "Wrong params"}))
    end
  end

  # Create new one
  post "/storage" do
    case conn.body_params do
      %{"key" => key, "value"  => value, "ttl" => ttl} ->
        KVstore.Storage.put(key, value, ttl)
        send_resp(conn, 200, Poison.encode!(%{msg: "OK. Will expire in #{ttl}"}))
      %{"key" => key, "value"  => value} ->
        KVstore.Storage.put(key, value)
        send_resp(conn, 200, Poison.encode!(%{msg: "OK"}))
      _ ->
        send_resp(conn, 200, Poison.encode!(%{msg: "Wrong params"}))
    end
  end

  get "/storage" do
    send_resp(conn, 200, Poison.encode!(KVstore.Storage.get_all))
  end

  match _, do: send_resp(conn, 404, "Oops!")
end
