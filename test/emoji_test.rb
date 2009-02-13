#!/usr/bin/env ruby

class DoCoMo < Test::Unit::TestCase
  SUN_DOCOMO_SJIS = "\xF8\x9F".force_encoding("Shift_JIS-DoCoMo")
  SUN_DOCOMO_UTF8 = "\u{e63e}".force_encoding("UTF-8-DoCoMo")
  def test_sjis_to_utf8
    assert_equal(SUN_DOCOMO_UTF8, SUN_DOCOMO_SJIS.encode("UTF-8-DoCoMo"))
  end
  def test_utf8_to_sjis
    assert_equal(SUN_DOCOMO_SJIS, SUN_DOCOMO_UTF8.encode("Shift_JIS-DoCoMo"))
  end
end

class Au < Test::Unit::TestCase
  SUN_AU_SJIS = "\xF6\x60".force_encoding("Shift_JIS-au")
  SUN_AU_UTF8 = "\u{e488}".force_encoding("UTF-8-au")
  def test_sjis_to_utf8
    assert_equal(SUN_AU_UTF8, SUN_AU_SJIS.encode("UTF-8-au"))
  end
  def test_utf8_to_sjis
    assert_equal(SUN_AU_SJIS, SUN_AU_UTF8.encode("Shift_JIS-au"))
  end
end
