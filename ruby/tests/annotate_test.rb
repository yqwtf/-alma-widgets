require 'minitest/autorun'
require 'open3'

describe "Junit annotate plugin parser" do
  it "handles no failures" do
    stdout, stderr, status = Open3.capture3("#{__dir__}/../bin/annotate", "#{__dir__}/no-test-failures/")

    assert_equal stderr, <<~OUTPUT
      Parsing junit-1.xml
      Parsing junit-2.xml
      Parsing junit-3.xml
      --- ✍️ Preparing annotation
    OUTPUT

    assert_equal stdout, <<~OUTPUT
      Failures: 0
      Errors: 0
      Total tests: 8
    OUTPUT

    assert_equal 0, status.exitstatus
  end

  it "handles failures across multiple files" do
    stdout, stderr, status = Open3.capture3("#{__dir__}/../bin/annotate", "#{__dir__}/two-test-failures/")

    assert_equal stderr, <<~OUTPUT
      Parsing junit-1.xml
      Parsing junit-2.xml
      Parsing junit-3.xml
      --- ✍️ Preparing annotation
    OUTPUT

    assert_equal stdout, <<~OUTPUT
      Failures: 4
      Errors: 0
      Total tests: 6
      
      <details>
      <summary><code>Account#maximum_jobs_added_by_pipeline_changer returns 250 by default in spec.models.account_spec</code></summary>
      
      <p>expected: 250 got: 500 (compared using eql?)</p>

      <pre><code>Failure/Error: expect(account.maximum_jobs_added_by_pipeline_changer).to eql(250)
      
        expected: 250
             got: 500
      
        (compared using eql?)
      ./spec/models/account_spec.rb:78:in `block (3 levels) in &lt;top (required)&gt;&#39;
      ./spec/support/database.rb:16:in `block (2 levels) in &lt;top (required)&gt;&#39;
      ./spec/support/log.rb:17:in `run&#39;
      ./spec/support/log.rb:66:in `block (2 levels) in &lt;top (required)&gt;&#39;</code></pre>
      
      in <a href="#1">Job #1</a>
      </details>
      
      <details>
      <summary><code>Account#maximum_jobs_added_by_pipeline_changer returns 700 if the account is XYZ in spec.models.account_spec</code></summary>
      
      <p>expected: 700 got: 500 (compared using eql?)</p>

      <pre><code>Failure/Error: expect(account.maximum_jobs_added_by_pipeline_changer).to eql(250)
      
        expected: 700
             got: 500
      
        (compared using eql?)
      ./spec/models/account_spec.rb:78:in `block (3 levels) in &lt;top (required)&gt;&#39;
      ./spec/support/database.rb:16:in `block (2 levels) in &lt;top (required)&gt;&#39;
      ./spec/support/log.rb:17:in `run&#39;
      ./spec/support/log.rb:66:in `block (2 levels) in &lt;top (required)&gt;&#39;</code></pre>
      
      in <a href="#2">Job #2</a>
      </details>

      <details>
      <summary><code>Account#maximum_jobs_added_by_pipeline_changer returns 700 if the account is XYZ in spec.models.account_spec</code></summary>
      
      <p>expected: 700 got: 500 (compared using eql?)</p>

      <pre><code>Failure/Error: expect(account.ma