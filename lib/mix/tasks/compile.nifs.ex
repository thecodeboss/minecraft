defmodule Mix.Tasks.Compile.Nifs do
  use Mix.Task

  @spec run(OptionParser.argv()) :: :ok
  def run(_args) do
    try do
      {result, 0} = System.cmd("make", [], stderr_to_stdout: true)
      IO.binwrite(result)
      Mix.Shell.IO.info("Successfully compiled NIFs")
    rescue
      e in MatchError ->
        {result, exit_code} = e.term
        Mix.Shell.IO.info("Failed to compile NIFs, exit code #{exit_code}:\n#{result}")

      err ->
        Mix.Shell.IO.info("Failed to compile NIFs, error: #{inspect(err)}")
    end

    :ok
  end
end
