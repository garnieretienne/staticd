require "test_helper"
require "staticd_utils/archive"
require "staticd_utils/sitemap"

class ArchiveTest < Minitest::Unit::TestCase
  include TestHelper

  def sample_archive(&block)
    archive = StaticdUtils::Archive.open_file(
      fixtures_path('files/mywebsite.fr.tar.gz')
    )
    yield archive
    archive.close
  end

  def mywebsite_base64
<<-EOF
H4sIAKbVaFQAA+3PwQrDIAwG4J77FL7BEqNRoey8N9h5amVQodDV95+HMnYq
gzLGwO/yExJIkjiEyJGS9JpVtI60c6Mk65kiGuU1BYs2dQcAALMSNdFoeM+N
ZIFSITFpBUYAstTUCTiy9FPlsd6WespUlnVvbiq77e0Z8co/MdzxfBlznsV1
XnIcTrXu+19f1TRN03zbE5w5Z+MACAAA
EOF
  end

  def test_archive_import_from_an_url_or_file_path
    sample_archive do |archive|
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

  def test_archive_creation_including_only_specified_files
    full_archive = StaticdUtils::Archive.create fixtures_path('sites/hello_world')
    partial_archive = StaticdUtils::Archive.create(
      fixtures_path('sites/hello_world'),
      ["/index.html"]
    )
    assert partial_archive.stream.read
    refute_equal partial_archive.size, full_archive.size
    full_archive.close
    partial_archive.close
  end

  def test_archive_export_to_file
    Dir.mktmpdir do |tmp|
      sample_archive do |archive|
        assert archive.to_file "#{tmp}/archive.tar.gz"
        assert File.exist? "#{tmp}/archive.tar.gz"
      end
    end
  end

  def test_archive_export_to_base64
    sample_archive do |archive|
      assert_equal mywebsite_base64, archive.to_base64
    end
  end

  def test_extract_archive
    Dir.mktmpdir do |tmp|
      sample_archive do |archive|
        archive.extract "#{tmp}"
        assert File.exist? "#{tmp}/f6ccd6d3f2b564d893599e238b63d174b53c818f"
      end
    end
  end

  def test_get_archive_size
    sample_archive do |archive|
      assert_instance_of Fixnum, archive.size
    end
  end

  def test_get_archive_stream_to_look_like_a_file
    sample_archive do |archive|
      duck_file = archive.to_archive_file
      assert_respond_to duck_file, :read
      assert_respond_to duck_file, :path
      assert_respond_to duck_file, :original_filename
      assert_respond_to duck_file, :content_type
    end
  end
end
