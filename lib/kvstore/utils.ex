defmodule KVstore.Utils do
  require Logger

  def dump_state(state) do
    mkdir =
      Application.get_env(:kvstore, :dump_file)
      |> Path.dirname
      |> File.mkdir_p

    case mkdir do
      :ok ->
        case File.write(Application.get_env(:kvstore, :dump_file), encode_data(state)) do
          :ok -> Logger.debug "Dump saved"
          _   -> Logger.debug "Error in saving dump file"
        end
      _ -> Logger.debug "Error in creating dir for dump file"
    end
  end

  def load_state do
    case Application.get_env(:kvstore, :dump_file) |> File.read do
      {:ok, data} ->
        data |> parse_data
      {:error, reason} ->
        Logger.debug inspect(reason)
        %{}
    end
  end

  defp parse_data(raw_data) when is_binary(raw_data) do
    case Poison.decode(raw_data) do
      {:ok, data} ->
        data
      {:error, error} ->
        Logger.debug "Error in parsing json #{inspect(error)}"
        %{}
      {:error, error, _} ->
        Logger.debug "Error in parsing json #{inspect(error)}"
        %{}
    end
  end

  defp parse_data(_), do: %{}


  defp encode_data(data) do
    case Poison.encode(data) do
      {:ok, json} ->
        json
      {:error, error} ->
        Logger.debug "Error in encoding json #{inspect(error)} #{inspect(data)}"
        ""
    end
  end
end
