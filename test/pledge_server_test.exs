defmodule PledgeServerTest do
  use ExUnit.Case, async: true

  import Servy.PledgeServer

  test "PledgeServer caches 3 most recent pledges" do
    # start the PledgeServer
    start()
    # send some pledges
    create_pledge("larry", 10)
    create_pledge("moe", 20)
    create_pledge("curly", 30)
    create_pledge("daisy", 40)
    create_pledge("grace", 50)
    # prepare test list
    most_recent_pledges = [{"grace", 50}, {"daisy", 40}, {"curly", 30}]
    # test the server's cache
    assert recent_pledges() == most_recent_pledges
    # test the server's total
    assert total_pledged() == 120
  end
end