require 'rubygems'
require 'hpricot'
require 'open-uri'
require 'kconv'
require 'erb'

$KCODE='u'

task :default => :test

task :all => ["build:table:all", "ruby:build"]

namespace :build do
  namespace :table do
    desc "generate conversion tables"
    task :all => [:docomo, :au, :softbank]

    task :docomo do
      table = []
      for type in %w(basic extention)
        uri = "http://www.nttdocomo.co.jp/service/imode/make/content/pictograph/#{type}/index.html"
        html = Kconv::kconv(open(uri).read, Kconv::UTF8, Kconv::SJIS)
        for tr in Hpricot(html)/'//table//tr'
          tds = (tr/'//td//span').map {|x| x.inner_text}
          table << tds unless tds.empty?
        end
      end
      erb = ERB.new(<<-EOT, nil, '-')
DOCOMO_SJIS_TO_UCS_TBL = [
<% for a in table -%>
  [<%= a[1].dump %>, 0x<%= a[3] %>], # <%= a[0] %>: <%= a[4] %> (<%= a[5] %>)
<% end -%>
]
DOCOMO_UCS_TO_SJIS_TBL = DOCOMO_SJIS_TO_UCS_TBL.map(&:reverse)
  EOT
      open("generated/emoji-docomo-tbl.rb", "w") do |f|
        f.write erb.result(binding)
      end
    end

    task :au do
      # 'au.txt' should be genarated from
      # http://www.au.kddi.com/ezfactory/tec/spec/pdf/typeD.pdf
      # by
      # - Preview.app on OSX; Select all and copy all, then paste it to text editor.
      # - xdoc2txt (described in http://moriq.tdiary.net/20070212.html#p01)
      table = []
      lines = File.read("au.txt")
      lines.scan( /(([0-9A-F] )+)/ ) do |s|
        s = s[0].gsub!(/ /, "")
        next if s.size < 16
        out = s[s.size-16,16]
        table << [0,4,8,12].map{|i| out[i,4]}
      end
      # output table
      erb = ERB.new(<<-EOT, nil, '-')
AU_SJIS_TO_UCS_TBL = [
<% for a in table -%>
  [<%= a[0].dump %>, 0x<%= a[1] %>],
<% end -%>
]
AU_UCS_TO_SJIS_TBL = AU_SJIS_TO_UCS_TBL.map(&:reverse)
AU_SJIS_TO_UCSAUTO_TBL = [
<% for a in table -%>
  [<%= a[0].dump %>, 0x<%= "%X" % (a[0].hex - 0x700) %>],
<% end -%>
]
AU_UCSAUTO_TO_SJIS_TBL = AU_SJIS_TO_UCSAUTO_TBL.map(&:reverse)
  EOT
      open("generated/emoji-au-tbl.rb", "w") do |f|
        f.write erb.result(binding)
      end
    end

    task :softbank do
      sjis_table = [
        [0xf941..0xf97e, 0xf980..0xf99b],
        [0xf741..0xf77e, 0xf780..0xf79b],
        [0xf7a1..0xf7f3],
        [0xf9a1..0xf9ed],
        [0xfb41..0xfb7e, 0xfb80..0xfb8d],
        [0xfba1..0xfbd7]
      ].map {|x| x.map {|y| y.to_a}.flatten}

      table = []
      for i in 1..6
        uri = "http://creation.mb.softbank.jp/web/web_pic_%02d.html" % i
        html = Kconv::kconv(open(uri).read, Kconv::UTF8, Kconv::SJIS)
        j = 0
        for tr in Hpricot(html)/%{//table/tr/td/table/tr/td/table[@width='100%']/tr}
          img,unicode,webcode_with_escape = (tr/'td').map {|x| x.inner_text.sub(/^\s*/, '')}
          next unless img.empty?
          if webcode_with_escape =~ /^\x1b\x24(..)\x0f$/
            webcode = $1
            sjis = "%04X" % sjis_table[i-1][j]
            table << [unicode, webcode, sjis]
            j += 1
          else
            raise "Something went wrong"
          end
        end
      end
      # output table
      erb = ERB.new(<<-EOT, nil, '-')
SOFTBANK_WEBCODE_TO_UCS_TBL = [
<% for a in table -%>
  [<%= a[1].dump %>, 0x<%= a[0] %>],
<% end -%>
]
SOFTBANK_UCS_TO_WEBCODE_TBL = SOFTBANK_WEBCODE_TO_UCS_TBL.map(&:reverse)
SOFTBANK_SJIS_TO_UCS_TBL = [
<% for a in table -%>
  [<%= a[2].dump %>, 0x<%= a[0] %>],
<% end -%>
]
SOFTBANK_UCS_TO_SJIS_TBL = SOFTBANK_SJIS_TO_UCS_TBL.map(&:reverse)
  EOT
      open("generated/emoji-softbank-tbl.rb", "w") do |f|
        f.write erb.result(binding)
      end
    end

    task :trans do
      num_to_str = {}
      conversion_table = Hash.new {|h,k| h[k] = {}}
      for name in %w(i2es e2is s2ie)
        uri = "http://labs.unoh.net/emoji_#{name}.txt"
        URI(uri).read.each_line do |l|
        next unless l =~ /^%/ # skip header line
          a = l.chomp.split("\t")
        num_to_str[a[0]] = a[1]
        to = a[2,2]
        to = ["", ""] if to.empty?
        conversion_table[name[0,1]][a[0]] = to
        end
      end
      erb = ERB.new(<<-EOT, nil, '-')
<% for from, to in conversion_table['i'] -%>
  [<%= num_to_str[from].dump %>, <%= (num_to_str[to[0]] || to[0].unpack('H*').first).dump %>],
<% end -%>
]
AUSJIS_TO_DOCOMOSJIS_TBL = [
<% for from, to in conversion_table['e'] -%>
  [<%= num_to_str[from].dump %>, <%= (num_to_str[to[0]] || to[0].unpack('H*').first).dump %>],
<% end -%>
]
  EOT
      open("generated/emoji-conversion-tbl.rb", "w") do |f|
        f.write erb.result(binding)
      end
    end
  end
end

# should be built in a better way ...
namespace :ruby do
  desc "fetch trunk of ruby"
  task :fetch do
    sh "svn co http://svn.ruby-lang.org/repos/ruby/trunk ruby"
  end
  desc "copy emoji codes into ruby source tree"
  task :patch do
    sh "cp generated/emoji-*tbl.rb emoji.trans ruby/enc/trans/"
  end
  desc "build ruby with emoji transcoder"
  task :build => [:fetch, :patch] do
    cd "ruby"
    sh "autoconf"
    sh "./configure"
    sh "./tool/build-transcode"
    sh "make"
  end
end

# should be written in a better way ...
task :test do
  emoji = FileList['ruby/.ext/**/enc/trans/emoji*'].first
  FileList['test/*_test.rb'].each do |test|
    sh "./ruby/ruby -I ruby/lib  -r #{emoji} -r test/unit #{test}"
  end
end
