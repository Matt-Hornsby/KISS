defmodule KissTest do
  use ExUnit.Case
  doctest Kiss

  @tag :skip
  test "README install version check" do
    app = :kiss

    app_version = "#{Application.spec(app, :vsn)}"
    readme = File.read!("README.md")
    [_, readme_versions] = Regex.run(~r/{:#{app}, "(.+)"}/, readme)

    assert Version.match?(
             app_version,
             readme_versions
           ),
           """
           Install version constraint in README.md does not match to current app version.
           Current App Version: #{app_version}
           Readme Install Versions: #{readme_versions}
           """
  end

  test "Should be able to extract destination address" do
    test_packet =
      <<146, 136, 64, 64, 64, 64, 96, 174, 174, 110, 164, 130, 64, 97, 3, 240, 87, 87, 55, 82, 65,
        47, 82, 32, 68, 73, 83, 65, 66, 76, 47, 66, 32, 87, 87, 55, 82, 65, 45, 55, 47, 78, 13>>

    message = Kiss.AX25Parser.parse(test_packet)

    assert message.destination_address == "ID"
  end

  test "1 in MSB of SSID field indicates should indicate that the message has been repeated" do
    ssid = <<0b10000000>>
    {:ok, result} = Kiss.AX25Parser.parse_ssid(ssid)
    assert result.has_been_repeated == true
  end

  test "Unrecognized packet should not cause crash" do
    test_packet = <<130, 160, 164, 176, 100, 112, 96, 174, 130, 110, 172>>
    {:err, reason} = Kiss.AX25Parser.parse(test_packet)

    assert reason != nil
  end
end
