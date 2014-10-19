require "test_helper"
require "staticd_utils/archive"

class ArchiveTest < MiniTest::Test
  include TestHelper

  def testing_archive(&block)
    archive = StaticdUtils::Archive.open_file(
      fixtures_path('files/mywebsite.fr.tar.gz')
    )
    yield archive
    archive.close
  end

  def mywebsite_base64
<<-EOF
H4sIAJ7bO1QAA8vMS0mt0Msoyc1hoBkwMDAwMzNRANKG5qYGyDQUGJkpGBqZ
GBqbGZuaGJgrGBgamRsaMSgY0M5JCFBaXJJYBHRKdmlRCT512aV4paGeUYDT
QwTYZBjaeaTm5OQrhOcX5aTY6AP5XFwD7apRMApGwSgYBbQGAHOa9g0ACAAA
EOF
  end

  def test_archive_import_from_an_url_or_file_path
    testing_archive do |archive|
      assert archive.stream.read
    end
  end

  def test_archive_import_from_a_base64_encoded_string
    archive = StaticdUtils::Archive.open_base64(mywebsite_base64)
    assert archive.stream.read
    archive.close
  end

  def test_archive_creation
    archive = StaticdUtils::Archive.create fixtures_path('sites/hello_world')
    assert archive.stream.read
    archive.close
  end

  def test_archive_export_to_file
    Dir.mktmpdir do |tmp|
      testing_archive do |archive|
        assert archive.to_file "#{tmp}/archive.tar.gz"
        assert File.exist? "#{tmp}/archive.tar.gz"
      end
    end
  end

  def test_archive_export_to_base64
    testing_archive do |archive|
      assert_equal mywebsite_base64, archive.to_base64
    end
  end

  def test_extract_archive
    Dir.mktmpdir do |tmp|
      testing_archive do |archive|
        archive.extract "#{tmp}"
        assert File.exist? "#{tmp}/index.html"
      end
    end
  end
end
