##### GRPC SETUP #####
require 'interservice/compliance/stats/stats_pb'
require 'interservice/compliance/stats/stats_services_pb'

if !ENV['NO_STATS_SUMMARY_TESTS']
  describe File.basename(__FILE__) do
    Stats = Chef::Automate::Domain::Compliance::Stats unless defined?(Stats)

    def stats;
      Stats::StatsService;
    end

    it "works" do
      ##### Failure tests #####
      actual_data = GRPC stats, :read_summary, Stats::Query.new(filters: [
          Stats::ListFilter.new(type: "profile_id", values: ["123"])
      ])
      expected_data = {
          "reportSummary" => {
              "status" => "unknown",
              "stats" => {}
          }
      }.to_json
      assert_equal(expected_data, actual_data.to_json)

      ##### Success tests #####
      # Get stats without end_time filter
      # This one is tricky to test because when no end_time is passed in, the backend (correctly) sets it to today.utc.
      # Without test scans being run every day, it is therefore very difficult to do..
      # Just make sure it comes back as listed in expected.
      actual_data = GRPC stats, :read_summary, Stats::Query.new()
      expected_data = {
          "reportSummary" => {
              "status" => "unknown",
              "stats" => {}
          }
      }.to_json
      assert_equal(expected_data, actual_data.to_json)


      # Get stats with end_time filter
      actual_data = GRPC stats, :read_summary, Stats::Query.new(filters: [
          Stats::ListFilter.new(type: 'end_time', values: ['2018-03-04T23:59:59Z'])
      ])
      expected_data = {
          "reportSummary" => {
              "status" => "failed",
              "stats" => {
                  "nodes" => "5",
                  "platforms" => 3,
                  "environments" => 3,
                  "profiles" => 3,
                  "nodesCnt" => 5,
                  "controls" => 18
              }
          }
      }.to_json
      assert_equal(expected_data, actual_data.to_json)


      # Filter by profile_id
      actual_data = GRPC stats, :read_summary, Stats::Query.new(filters: [
          Stats::ListFilter.new(type: "profile_id", values: ["09adcbb3b9b3233d5de63cd98a5ba3e155b3aaeb66b5abed379f5fb1ff143988"]),
          Stats::ListFilter.new(type: 'end_time', values: ['2018-03-04T23:59:59Z'])
      ])
      expected_data = {
          "reportSummary" => {
              "status" => "failed",
              "stats" => {
                  "nodes" => "4",
                  "platforms" => 2,
                  "environments" => 2,
                  "profiles" => 1,
                  "nodesCnt" => 4,
                  "controls" => 4
              }
          }
      }.to_json
      assert_equal(expected_data, actual_data.to_json)

      # Filter by a waived profile
      actual_data = GRPC stats, :read_summary, Stats::Query.new(filters: [
          Stats::ListFilter.new(type: "profile_id", values: ["447542ecfb8a8800ed0146039da3af8fed047f575f6037cfba75f3b664a97ea5"]),
          Stats::ListFilter.new(type: 'end_time', values: ['2018-04-01T23:59:59Z'])
      ])
      expected_data = {
          "reportSummary" => {
              "status" => "waived",
              "stats" => {
                  "nodes" => "2",
                  "platforms" => 1,
                  "environments" => 1,
                  "profiles" => 1,
                  "nodesCnt" => 2,
                  "controls" => 1
              }
          }
      }.to_json
      assert_equal(expected_data, actual_data.to_json)

      # Filter by a failed profile with a few waived controls, but not all of them
      actual_data = GRPC stats, :read_summary, Stats::Query.new(filters: [
          Stats::ListFilter.new(type: "profile_id", values: ["447542ecfb8a8800ed0146039da3af8fed047f575f6037cfba75f3b664a97ea4"]),
          Stats::ListFilter.new(type: 'end_time', values: ['2018-04-01T23:59:59Z'])
      ])
      expected_data = {
          "reportSummary" => {
              "status" => "failed",
              "stats" => {
                  "nodes" => "1",
                  "platforms" => 1,
                  "environments" => 1,
                  "profiles" => 1,
                  "nodesCnt" => 1,
                  "controls" => 5
              }
          }
      }.to_json
      assert_equal(expected_data, actual_data.to_json)

      # Filter by control tag
      actual_data = GRPC stats, :read_summary, Stats::Query.new(filters: [
          Stats::ListFilter.new(type: 'end_time', values: ['2018-03-04T23:59:59Z']),
          Stats::ListFilter.new(type: 'control_tag:scope', values: ['nginx', 'Apache'])
      ])
      expected_data = {
          "reportSummary" => {
              "status" => "failed",
              "stats" => {
                  "nodes" => "3",
                  "platforms" => 3,
                  "environments" => 2,
                  "profiles" => 3,
                  "nodesCnt" => 3,
                  "controls" => 18
              }
          }
      }.to_json
      assert_equal(expected_data, actual_data.to_json)

      # Filter by job_id
      actual_data = GRPC stats, :read_summary, Stats::Query.new(filters: [
          Stats::ListFilter.new(type: "job_id", values: ["74a54a28-c628-4f82-86df-444444444444"]),
          Stats::ListFilter.new(type: 'end_time', values: ['2018-03-04T23:59:59Z'])
      ])
      expected_data = {
          "reportSummary" => {
              "status" => "skipped",
              "stats" => {
                  "nodes" => "1",
                  "platforms" => 1,
                  "environments" => 1,
                  "profiles" => 1,
                  "nodesCnt" => 1,
                  "controls" => 14
              }
          }
      }.to_json
      assert_equal(expected_data, actual_data.to_json)


      # Filter by multiple profile_ids
      actual_data = GRPC stats, :read_summary, Stats::Query.new(filters: [
          Stats::ListFilter.new(type: "profile_id", values: [
              "41a02784bfea15592ba2748d55927d8d1f9da205816ef18d3bb2ebe4c5ce18a9", "09adcbb3b9b3233d5de63cd98a5ba3e155b3aaeb66b5abed379f5fb1ff143988"
          ]),
          Stats::ListFilter.new(type: 'end_time', values: ['2018-03-04T23:59:59Z'])
      ])
      expected_data = {
          "reportSummary" => {
              "status" => "failed",
              "stats" => {
                  "nodes" => "5",
                  "platforms" => 3,
                  "environments" => 3,
                  "profiles" => 2,
                  "nodesCnt" => 5,
                  "controls" => 18
              }
          }
      }.to_json
      assert_equal(expected_data, actual_data.to_json)


      # Filter by node_id
      actual_data = GRPC stats, :read_summary, Stats::Query.new(filters: [
          Stats::ListFilter.new(type: "node_id", values: ["9b9f4e51-b049-4b10-9555-10578916e149"]),
          Stats::ListFilter.new(type: 'end_time', values: ['2018-03-04T23:59:59Z'])
      ])
      expected_data = {
          "reportSummary" => {
              "status" => "passed",
              "stats" => {
                  "nodes" => "1",
                  "platforms" => 1,
                  "environments" => 1,
                  "profiles" => 3,
                  "nodesCnt" => 1,
                  "controls" => 18
              }
          }
      }.to_json
      assert_equal(expected_data, actual_data.to_json)


      # Filter by a waived node
      actual_data = GRPC stats, :read_summary, Stats::Query.new(filters: [
          Stats::ListFilter.new(type: "node_id", values: ["34cbbb55-c502-4971-2222-999999999999"]),
          Stats::ListFilter.new(type: 'end_time', values: ['2018-04-01T23:59:59Z'])
      ])
      expected_data = {
          "reportSummary" => {
              "status" => "waived",
              "stats" => {
                  "nodes" => "1",
                  "platforms" => 1,
                  "environments" => 1,
                  "profiles" => 1,
                  "nodesCnt" => 1,
                  "controls" => 1
              }
          }
      }.to_json
      assert_equal(expected_data, actual_data.to_json)

      # Filter by node_id and profile_id where profile ran on node
      actual_data = GRPC stats, :read_summary, Stats::Query.new(filters: [
          Stats::ListFilter.new(type: "node_id", values: ["9b9f4e51-b049-4b10-9555-10578916e149"]),
          Stats::ListFilter.new(type: "profile_id", values: ["09adcbb3b9b3233d5de63cd98a5ba3e155b3aaeb66b5abed379f5fb1ff143988"]),
          Stats::ListFilter.new(type: 'end_time', values: ['2018-03-04T23:59:59Z'])
      ])
      expected_data = {
          "reportSummary" => {
              "status" => "passed",
              "stats" => {
                  "nodes" => "1",
                  "platforms" => 1,
                  "environments" => 1,
                  "profiles" => 1,
                  "nodesCnt" => 1,
                  "controls" => 4
              }
          }
      }.to_json
      assert_equal(expected_data, actual_data.to_json)


      # Filter by node_id and profile_id where profile did not run on node
      actual_data = GRPC stats, :read_summary, Stats::Query.new(filters: [
          Stats::ListFilter.new(type: "node_id", values: ["9b9f4e51-b049-4b10-9555-10578916e149"]),
          Stats::ListFilter.new(type: "profile_id", values: ["b53ca05fbfe17a36363a40f3ad5bd70aa20057eaf15a9a9a8124a84d4ef08015"]),
          Stats::ListFilter.new(type: 'end_time', values: ['2018-03-04T23:59:59Z'])
      ])
      expected_data = {
          "reportSummary" => {
              "status" => "unknown",
              "stats" => {}
          }
      }.to_json
      assert_equal(expected_data, actual_data.to_json)


      # Filter by environment and profile_id where profile ran in environment
      actual_data = GRPC stats, :read_summary, Stats::Query.new(filters: [
          Stats::ListFilter.new(type: "environment", values: ["DevSec Prod Zeta"]),
          Stats::ListFilter.new(type: "profile_id", values: ["41a02784bfea15592ba2748d55927d8d1f9da205816ef18d3bb2ebe4c5ce18a9"]),
          Stats::ListFilter.new(type: 'end_time', values: ['2018-03-04T23:59:59Z'])
      ])
      expected_data = {
          "reportSummary" => {
              "status" => "skipped",
              "stats" => {
                  "nodes" => "1",
                  "platforms" => 1,
                  "environments" => 1,
                  "profiles" => 1,
                  "nodesCnt" => 1,
                  "controls" => 14
              }
          }
      }.to_json
      assert_equal(expected_data, actual_data.to_json)


      # Filter by environment and profile_id where profile did not run in environment
      actual_data = GRPC stats, :read_summary, Stats::Query.new(filters: [
          Stats::ListFilter.new(type: "environment", values: ["DevSec Prod Missing"]),
          Stats::ListFilter.new(type: "profile_id", values: ["41a02784bfea15592ba2748d55927d8d1f9da205816ef18d3bb2ebe4c5ce18a9"]),
          Stats::ListFilter.new(type: 'end_time', values: ['2018-03-04T23:59:59Z'])
      ])
      expected_data = {
          "reportSummary" => {
              "status" => "unknown",
              "stats" => {}
          }
      }.to_json
      assert_equal(expected_data, actual_data.to_json)


      # Filter by platform and profile_id where profile ran on nodes on platform
      actual_data = GRPC stats, :read_summary, Stats::Query.new(filters: [
          Stats::ListFilter.new(type: "platform", values: ["windows"]),
          Stats::ListFilter.new(type: "profile_id", values: ["41a02784bfea15592ba2748d55927d8d1f9da205816ef18d3bb2ebe4c5ce18a9"]),
          Stats::ListFilter.new(type: 'end_time', values: ['2018-03-04T23:59:59Z'])
      ])
      expected_data = {
          "reportSummary" => {
              "status" => "skipped",
              "stats" => {
                  "nodes" => "1",
                  "platforms" => 1,
                  "environments" => 1,
                  "profiles" => 1,
                  "nodesCnt" => 1,
                  "controls" => 14
              }
          }
      }.to_json
      assert_equal(expected_data, actual_data.to_json)


      # Filter by platform and all profiles that ran on nodes of filtered platform
      actual_data = GRPC stats, :read_summary, Stats::Query.new(filters: [
          Stats::ListFilter.new(type: "platform", values: ["centos"]),
          Stats::ListFilter.new(type: 'end_time', values: ['2018-03-04T23:59:59Z'])
      ])
      expected_data = {
          "reportSummary" => {
              "status" => "passed",
              "stats" => {
                  "nodes" => "1",
                  "platforms" => 1,
                  "environments" => 1,
                  "profiles" => 3,
                  "nodesCnt" => 1,
                  "controls" => 18
              }
          }
      }.to_json
      assert_equal(expected_data, actual_data.to_json)


      # Filter by platform and all profiles that ran on nodes of filtered platform
      actual_data = GRPC stats, :read_summary, Stats::Query.new(filters: [
          Stats::ListFilter.new(type: "platform", values: ["debian"]),
          Stats::ListFilter.new(type: "status", values: ["failed"]),
          Stats::ListFilter.new(type: 'end_time', values: ['2018-02-09T23:59:59Z'])
      ])
      expected_data = {
          "reportSummary" => {
              "status" => "failed",
              "stats" => {
                  "nodes" => "1",
                  "platforms" => 1,
                  "environments" => 1,
                  "profiles" => 2,
                  "nodesCnt" => 1,
                  "controls" => 59
              }
          }
      }.to_json
      assert_equal(expected_data, actual_data.to_json)


      ##Deep filtering
      # todo -check these numbers well.. in addition to these tests, look closely at our es indices and make sure they are all good

      # Filter by profile_id
      actual_data = GRPC stats, :read_summary, Stats::Query.new(filters: [
          Stats::ListFilter.new(type: "profile_id", values: ["09adcbb3b9b3233d5de63cd98a5ba3e155b3aaeb66b5abed379f5fb1ff143988"]),
          Stats::ListFilter.new(type: 'end_time', values: ['2018-03-04T23:59:59Z'])
      ])
      expected_data = {
          "reportSummary" => {
              "status" => "failed",
              "stats" => {
                  "nodes" => "4",
                  "platforms" => 2,
                  "environments" => 2,
                  "profiles" => 1,
                  "nodesCnt" => 4,
                  "controls" => 4
              }
          }
      }.to_json
      assert_equal(expected_data, actual_data.to_json)

      # Filter by profile_id
      # apache-baseline is skipped on centos
      actual_data = GRPC stats, :read_summary, Stats::Query.new(filters: [
          Stats::ListFilter.new(type: "profile_id", values: ["41a02784bfea15592ba2748d55927d8d1f9da205816ef18d3bb2ebe4c5ce18a9"]),
          Stats::ListFilter.new(type: 'end_time', values: ['2018-03-04T23:59:59Z']),
          Stats::ListFilter.new(type: "platform", values: ["centos"])
      ])
      expected_data = {
          "reportSummary" => {
              "status" => "skipped",
              "stats" => {
                  "nodes" => "1",
                  "platforms" => 1,
                  "environments" => 1,
                  "profiles" => 1,
                  "nodesCnt" => 1,
                  "controls" => 14
              }
          }
      }.to_json
      assert_equal(expected_data, actual_data.to_json)

      # Filter by profile_id
      # nginx-baseline passes on centos
      actual_data = GRPC stats, :read_summary, Stats::Query.new(filters: [
          Stats::ListFilter.new(type: "profile_id", values: ["09adcbb3b9b3233d5de63cd98a5ba3e155b3aaeb66b5abed379f5fb1ff143988"]),
          Stats::ListFilter.new(type: 'end_time', values: ['2018-03-04T23:59:59Z']),
          Stats::ListFilter.new(type: "platform", values: ["centos"])
      ])
      expected_data = {
          "reportSummary" => {
              "status" => "passed",
              "stats" => {
                  "nodes" => "1",
                  "platforms" => 1,
                  "environments" => 1,
                  "profiles" => 1,
                  "nodesCnt" => 1,
                  "controls" => 4
              }
          }
      }.to_json
      assert_equal(expected_data, actual_data.to_json)

      # Filter by control_id
      actual_data = GRPC stats, :read_summary, Stats::Query.new(filters: [
          Stats::ListFilter.new(type: "profile_id", values: ["09adcbb3b9b3233d5de63cd98a5ba3e155b3aaeb66b5abed379f5fb1ff143988"]),
          Stats::ListFilter.new(type: 'end_time', values: ['2018-03-04T23:59:59Z']),
          Stats::ListFilter.new(type: 'control', values: ['nginx-01'])
      ])
      expected_data = {
          "reportSummary" => {
              "status" => "failed",
              "stats" => {
                  "nodes" => "4",
                  "platforms" => 2,
                  "environments" => 2,
                  "profiles" => 1,
                  "nodesCnt" => 4,
                  "controls" => 1
              }
          }
      }.to_json
      assert_equal(expected_data, actual_data.to_json)

      # Filter by control_id
      actual_data = GRPC stats, :read_summary, Stats::Query.new(filters: [
          Stats::ListFilter.new(type: "profile_id", values: ["09adcbb3b9b3233d5de63cd98a5ba3e155b3aaeb66b5abed379f5fb1ff143988"]),
          Stats::ListFilter.new(type: 'end_time', values: ['2018-03-04T23:59:59Z']),
          Stats::ListFilter.new(type: 'control', values: ['nginx-01']),
          Stats::ListFilter.new(type: "platform", values: ["centos"])
      ])
      expected_data = {
          "reportSummary" => {
              "status" => "passed", #look at this business! yes! for this control, we have a status of passed! notice the test above, we had 4 nodes with a status of failed
              "stats" => {
                  "nodes" => "1",
                  "platforms" => 1,
                  "environments" => 1,
                  "profiles" => 1,
                  "nodesCnt" => 1,
                  "controls" => 1
              }
          }
      }.to_json
      assert_equal(expected_data, actual_data.to_json)

      # Filter by a waived control
      actual_data = GRPC stats, :read_summary, Stats::Query.new(filters: [
          Stats::ListFilter.new(type: "profile_id", values: ["447542ecfb8a8800ed0146039da3af8fed047f575f6037cfba75f3b664a97ea4"]),
          Stats::ListFilter.new(type: 'end_time', values: ['2018-04-01T23:59:59Z']),
          Stats::ListFilter.new(type: 'control', values: ['pro1-con4'])
      ])
      expected_data = {
          "reportSummary" => {
              "status" => "waived",
              "stats" => {
                  "nodes" => "1",
                  "platforms" => 1,
                  "environments" => 1,
                  "profiles" => 1,
                  "nodesCnt" => 1,
                  "controls" => 1
              }
          }
      }.to_json
      assert_equal(expected_data, actual_data.to_json)

      # Filter by an expired waived control that failed in a profile that has mostly waived controls
      actual_data = GRPC stats, :read_summary, Stats::Query.new(filters: [
          Stats::ListFilter.new(type: "profile_id", values: ["447542ecfb8a8800ed0146039da3af8fed047f575f6037cfba75f3b664a97ea4"]),
          Stats::ListFilter.new(type: 'end_time', values: ['2018-04-01T23:59:59Z']),
          Stats::ListFilter.new(type: 'control', values: ['pro1-con3'])
      ])
      expected_data = {
          "reportSummary" => {
              "status" => "failed",
              "stats" => {
                  "nodes" => "1",
                  "platforms" => 1,
                  "environments" => 1,
                  "profiles" => 1,
                  "nodesCnt" => 1,
                  "controls" => 1
              }
          }
      }.to_json
      assert_equal(expected_data, actual_data.to_json)


      # Compliance Summary with role filters
      actual_data = GRPC stats, :read_summary, Stats::Query.new(
          filters: [
              Stats::ListFilter.new(type: "role", values: ["apache_deb", "missing"]),
              Stats::ListFilter.new(type: 'end_time', values: ['2018-02-09T23:59:59Z'])
          ]
      )
      expected_data = {
          "reportSummary" => {
              "status" => "failed",
              "stats" => {
                  "nodesCnt" => 1,
                  "nodes" => "1",
                  "platforms" => 1,
                  "environments" => 1,
                  "profiles" => 2,
                  "controls" => 59
              }
          }
      }
      assert_equal_json_content(expected_data, actual_data)


      #### nodes summary

      # Compliance Summary without filters
      actual_data = GRPC stats, :read_summary, Stats::Query.new(
          type: "nodes",
          filters: [
              Stats::ListFilter.new(type: 'end_time', values: ['2018-03-04T23:59:59Z'])
          ])
      expected_data = {
          "nodeSummary" => {
              "compliant" => 1,
              "skipped" => 1,
              "noncompliant" => 3,
              "highRisk" => 3
          }
      }
      assert_equal_json_content(expected_data, actual_data)

      # Compliance Summary without filters for a node skipped due to unsupported os
      actual_data = GRPC stats, :read_summary, Stats::Query.new(
          type: "nodes",
          filters: [
              Stats::ListFilter.new(type: 'end_time', values: ['2018-03-07T23:59:59Z'])
          ])
      expected_data = {
          "nodeSummary" => {
              "skipped" => 1
          }
      }
      assert_equal_json_content(expected_data, actual_data)

      # Compliance Summary Nodes with filters
      actual_data = GRPC stats, :read_summary, Stats::Query.new(
          type: "nodes",
          filters: [
              Stats::ListFilter.new(type: "platform", values: ["centos"]),
              Stats::ListFilter.new(type: 'end_time', values: ['2018-03-04T23:59:59Z'])
          ]
      )
      expected_data = {
          "nodeSummary" => {
              "compliant" => 1
          }
      }
      assert_equal_json_content(expected_data, actual_data)


      actual_data = GRPC stats, :read_summary, Stats::Query.new(
          type: "nodes",
          filters: [
              Stats::ListFilter.new(type: "platform", values: ["windows"]),
              Stats::ListFilter.new(type: "status", values: ["skipped"]),
              Stats::ListFilter.new(type: 'end_time', values: ['2018-03-04T23:59:59Z'])
          ]
      )
      expected_data = {
          "nodeSummary" => {
              "skipped" => 1
          }
      }
      assert_equal_json_content(expected_data, actual_data)


      actual_data = GRPC stats, :read_summary, Stats::Query.new(
          type: "nodes",
          filters: [
              Stats::ListFilter.new(type: "platform", values: ["debian"]),
              Stats::ListFilter.new(type: 'start_time', values: ['2018-02-04T23:59:59Z']),
              Stats::ListFilter.new(type: 'end_time', values: ['2018-02-09T23:59:59Z'])
          ]
      )
      expected_data = {
          "nodeSummary" => {
              "noncompliant" => 1,
              "highRisk" => 1
          }
      }
      assert_equal_json_content(expected_data, actual_data)

      # Compliance Summary Nodes with recipe filter
      actual_data = GRPC stats, :read_summary, Stats::Query.new(
          type: "nodes",
          filters: [
              Stats::ListFilter.new(type: "recipe", values: ["apache_extras::windows_harden", "missing.in.action"]),
              Stats::ListFilter.new(type: 'end_time', values: ['2018-03-04T23:59:59Z'])
          ]
      )
      expected_data = {
          "nodeSummary" => {
              "skipped" => 1
          }
      }
      assert_equal_json_content(expected_data, actual_data)


      #### control summary

      # Global Compliancy across all controls
      actual_data = GRPC stats, :read_summary, Stats::Query.new(
          type: "controls",
          filters: [
              Stats::ListFilter.new(type: 'start_time', values: ['2018-03-02T23:59:59Z']),
              Stats::ListFilter.new(type: 'end_time', values: ['2018-03-05T23:59:59Z'])
          ]
      )
      expected_data = {
          "controlsSummary" => {
              "passed" => 3,
              "skipped" => 15
          }
      }
      assert_equal_json_content(expected_data, actual_data)

      #description: Control stats list for nodes.
      #calls: stats::ReadSummary::GetStatsSummaryControls
      #depth: Report
      actual_data = GRPC stats, :read_summary, Stats::Query.new(
          type: "controls",
          filters: [
              Stats::ListFilter.new(type: "role", values: ["dot.role", "debian-hardening-prod"]),
              Stats::ListFilter.new(type: 'end_time', values: ['2018-02-09T23:59:59Z']),
              Stats::ListFilter.new(type: "status", values: ["failed"])
          ]
      )
      expected_data = {
          "controlsSummary" => {
              "failures" => 21,
              "criticals" => 21,
              "passed" => 23,
              "skipped" => 12,
              "waived" => 3
          }
      }
      assert_equal_json_content(expected_data, actual_data)

      # Get stats with end_time filter for the faily/skippy 04-02 date
      actual_data = GRPC stats, :read_summary, Stats::Query.new(
        filters: [
          Stats::ListFilter.new(type: 'end_time', values: ['2018-04-02T23:59:59Z'])
        ])
      expected_data = {
        "reportSummary": {
          "status": "failed",
          "stats": {
            "nodes": "1",
            "platforms": 1,
            "environments": 1,
            "profiles": 4,
            "nodesCnt": 1,
            "controls": 1
          }
        }
      }.to_json
      assert_equal(expected_data, actual_data.to_json)

      # Get stats with end_time filter for the root fail 04-03 date
      actual_data = GRPC stats, :read_summary, Stats::Query.new(
        filters: [
          Stats::ListFilter.new(type: 'end_time', values: ['2018-04-03T23:59:59Z'])
        ])
      expected_data = {
        "reportSummary": {
          "status": "failed",
          "stats": {
            "nodes": "1",
            "platforms": 1,
            "environments": 1,
            "nodesCnt": 1
          }
        }
      }.to_json
      assert_equal(expected_data, actual_data.to_json)

    end
  end
end
