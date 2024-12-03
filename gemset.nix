{
  actioncable = {
    dependencies = ["actionpack" "activesupport" "nio4r" "websocket-driver" "zeitwerk"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "046k9cnw8vqlf4q4i2aywr5rf02k2081238z2rf3vada3ijshyvq";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "7.1.3.4";
  };
  actionmailbox = {
    dependencies = ["actionpack" "activejob" "activerecord" "activestorage" "activesupport" "mail" "net-imap" "net-pop" "net-smtp"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1l6ahdd20zimpq8crfw9ng8w288giv3daklbw6df95s5lhck1zd3";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "7.1.3.4";
  };
  actionmailer = {
    dependencies = ["actionpack" "actionview" "activejob" "activesupport" "mail" "net-imap" "net-pop" "net-smtp" "rails-dom-testing"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0l835a50h95wlzcy76c2vg54ix3i55kqmnrmz67b11q5fjb6068z";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "7.1.3.4";
  };
  actionpack = {
    dependencies = ["actionview" "activesupport" "nokogiri" "racc" "rack" "rack-session" "rack-test" "rails-dom-testing" "rails-html-sanitizer"];
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1lpd0lvn6abcq5k8g0qw8kmzx6igirlqxvd1hhwmr5vaxhdwgbyw";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "7.1.3.4";
  };
  actiontext = {
    dependencies = ["actionpack" "activerecord" "activestorage" "activesupport" "globalid" "nokogiri"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "115p772dc19qvywyz9pgzh1fb3g2457hhh96shcrijd3jnp4v5l4";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "7.1.3.4";
  };
  actionview = {
    dependencies = ["activesupport" "builder" "erubi" "rails-dom-testing" "rails-html-sanitizer"];
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0nv1ifjhm59abc52k2hwazl38r9cc4bkfgdsl00f24gc5ljgbz21";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "7.1.3.4";
  };
  activejob = {
    dependencies = ["activesupport" "globalid"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0qhg0izdckgyqmrsgigh1vkqg8ccrkdjhf36k9gxcbgvzpqfx2iz";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "7.1.3.4";
  };
  activemodel = {
    dependencies = ["activesupport"];
    groups = ["default" "development"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0wmdw440l4h75zk6c4ynbnv21bj26dh8kb1kwikqkjnzfvm3ij7l";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "7.1.3.4";
  };
  activerecord = {
    dependencies = ["activemodel" "activesupport" "timeout"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1wihj9xhr7yj10hh8fqw6ralanbwlisncbam8pa92czjssjfqkkq";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "7.1.3.4";
  };
  activestorage = {
    dependencies = ["actionpack" "activejob" "activerecord" "activesupport" "marcel"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0bhardfnmyynd04si8989g5yw5fnj4f2a5cs1945w43ylyh0w0pj";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "7.1.3.4";
  };
  activesupport = {
    dependencies = ["base64" "bigdecimal" "concurrent-ruby" "connection_pool" "drb" "i18n" "minitest" "mutex_m" "tzinfo"];
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0283wk1zxb76lg79dk501kcf5xy9h25qiw15m86s4nrfv11vqns5";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "7.1.3.4";
  };
  addressable = {
    dependencies = ["public_suffix"];
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "05r1fwy487klqkya7vzia8hnklcxy4vr92m9dmni3prfwk6zpw33";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "2.8.5";
  };
  ast = {
    groups = ["default" "development"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "04nc8x27hlzlrr5c2gn7mar4vdr0apw5xg22wp6m8dx3wqr04a0y";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "2.4.2";
  };
  aws-eventstream = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1pyis1nvnbjxk12a43xvgj2gv0mvp4cnkc1gzw0v1018r61399gz";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "1.2.0";
  };
  aws-partitions = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1dwbam5xq2vz03y9n2s045mnik541h6pns2axw9ziqz2qgg6j820";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "1.831.0";
  };
  aws-record = {
    dependencies = ["aws-sdk-dynamodb"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0g0mscdmgn5zrl30s2dzl8yb70az0a1phbsslm0cj9qrqdh3xzj9";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "2.12.0";
  };
  aws-sdk-core = {
    dependencies = ["aws-eventstream" "aws-partitions" "aws-sigv4" "jmespath"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "00yvf0712z2pn4v50dpfbdkwfj6f710wpprl2wc2715xaalyk3rc";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "3.185.0";
  };
  aws-sdk-dynamodb = {
    dependencies = ["aws-sdk-core" "aws-sigv4"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1ff1g8rn9d03bvvsdkp4wbafngxxigznazxhx60pkjhqpi80j5il";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "1.95.0";
  };
  aws-sdk-rails = {
    dependencies = ["aws-record" "aws-sdk-ses" "aws-sdk-sesv2" "aws-sdk-sqs" "aws-sessionstore-dynamodb" "concurrent-ruby" "railties"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0gzqmqhrigdsvk6zywk9v6yvgqjzk1xvyb286nc0404g4vr2szb6";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "3.9.0";
  };
  aws-sdk-ses = {
    dependencies = ["aws-sdk-core" "aws-sigv4"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "14q1pnmyi472x6k63syz10qmx35gcxsgca7il0svg30n585f6naq";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "1.56.0";
  };
  aws-sdk-sesv2 = {
    dependencies = ["aws-sdk-core" "aws-sigv4"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0bapkfx8pj1hqixslcx1c60k1l37xzcsssv2dx83vyd1glgbm1y7";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "1.40.0";
  };
  aws-sdk-sqs = {
    dependencies = ["aws-sdk-core" "aws-sigv4"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "02wv7kj0dipqxmqckwhd8l7ydm2c8s9l3pw8f4vgm3wr4wgqbw1y";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "1.64.0";
  };
  aws-sessionstore-dynamodb = {
    dependencies = ["aws-sdk-dynamodb" "rack"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1j2dqkbgxgibyfhvx3lyp64ifm042r2kpx57iynqcx5y8azz3lpb";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "2.1.0";
  };
  aws-sigv4 = {
    dependencies = ["aws-eventstream"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0z889c4c1w7wsjm3szg64ay5j51kjl4pdf94nlr1yks2rlanm7na";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "1.6.0";
  };
  backport = {
    groups = ["default" "development"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0xbzzjrgah0f8ifgd449kak2vyf30micpz6x2g82aipfv7ypsb4i";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "1.2.0";
  };
  base64 = {
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "01qml0yilb9basf7is2614skjp8384h2pycfx86cr8023arfj98g";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "0.2.0";
  };
  benchmark = {
    groups = ["default" "development"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0wghmhwjzv4r9mdcny4xfz2h2cm7ci24md79rvy2x65r4i99k9sc";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "0.3.0";
  };
  bigdecimal = {
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1gi7zqgmqwi5lizggs1jhc3zlwaqayy9rx2ah80sxy24bbnng558";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "3.1.8";
  };
  bindex = {
    groups = ["default" "development"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0zmirr3m02p52bzq4xgksq4pn8j641rx5d4czk68pv9rqnfwq7kv";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "0.8.1";
  };
  bootsnap = {
    dependencies = ["msgpack"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0iqkzby0fdgi786m873nm0ckmc847wy9a4ydinb29m7hd3fs83kb";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "1.17.0";
  };
  brakeman = {
    dependencies = ["racc"];
    groups = ["test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1lylig4vgnw9l1ybwgxdi9nw9q2bc5dcplklg8nsbi7j32f7c5kp";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "6.1.2";
  };
  builder = {
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0pw3r2lyagsxkm71bf44v5b74f7l9r7di22brbyji9fwz791hya9";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "3.3.0";
  };
  byebug = {
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0nx3yjf4xzdgb8jkmk2344081gqr22pgjqnmjg2q64mj5d6r9194";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "11.1.3";
  };
  capybara = {
    dependencies = ["addressable" "matrix" "mini_mime" "nokogiri" "rack" "rack-test" "regexp_parser" "xpath"];
    groups = ["test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "114qm5f5vhwaaw9rj1h2lcamh46zl13v1m18jiw68zl961gwmw6n";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "3.39.2";
  };
  coderay = {
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0jvxqxzply1lwp7ysn94zjhh57vc14mcshw1ygw14ib8lhc00lyw";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "1.1.3";
  };
  concurrent-ruby = {
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0skwdasxq7mnlcccn6aqabl7n9r3jd7k19ryzlzzip64cn4x572g";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "1.3.3";
  };
  connection_pool = {
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1x32mcpm2cl5492kd6lbjbaf17qsssmpx9kdyr7z1wcif2cwyh0g";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "2.4.1";
  };
  crack = {
    dependencies = ["rexml"];
    groups = ["default" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1cr1kfpw3vkhysvkk3wg7c54m75kd68mbm9rs5azdjdq57xid13r";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "0.4.5";
  };
  crass = {
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0pfl5c0pyqaparxaqxi6s4gfl21bdldwiawrc0aknyvflli60lfw";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "1.0.6";
  };
  cuprite = {
    dependencies = ["capybara" "ferrum"];
    groups = ["test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1piq0q370xka10fzm1p34il7h9fg76xl207bykn67p8swqrq79rb";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "0.15";
  };
  date = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "149jknsq999gnhy865n33fkk22s0r447k76x9pmcnnwldfv2q7wp";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "3.3.6";
  };
  diff-lcs = {
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0rwvjahnp7cpmracd8x732rjgnilqv2sx7d1gfrysslc3h039fa9";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "1.5.0";
  };
  docile = {
    groups = ["default" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1lxqxgq71rqwj1lpl9q1mbhhhhhhdkkj7my341f2889pwayk85sz";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "1.4.0";
  };
  dotenv = {
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1n0pi8x8ql5h1mijvm8lgn6bhq4xjb5a500p5r1krq4s6j9lg565";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "2.8.1";
  };
  dotenv-rails = {
    dependencies = ["dotenv" "railties"];
    groups = ["development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0v0gcbxzypcvy6fqq4gp80jb310xvdwj5n8qw9ci67g5yjvq2nxh";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "2.8.1";
  };
  drb = {
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0h5kbj9hvg5hb3c7l425zpds0vb42phvln2knab8nmazg2zp5m79";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "2.2.1";
  };
  e2mmap = {
    groups = ["default" "development"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0n8gxjb63dck3vrmsdcqqll7xs7f3wk78mw8w0gdk9wp5nx6pvj5";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "0.1.0";
  };
  erubi = {
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0qnd6ff4az22ysnmni3730c41b979xinilahzg86bn7gv93ip9pw";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "1.13.0";
  };
  factory_bot = {
    dependencies = ["activesupport"];
    groups = ["default" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1glq677vmd3xrdilcx6ar8sdaysm9ldrppg34yzw43jzr6dx47fp";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "6.4.5";
  };
  factory_bot_rails = {
    dependencies = ["factory_bot" "railties"];
    groups = ["test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1j6w4rr2cb5wng9yrn2ya9k40q52m0pbz47kzw8xrwqg3jncwwza";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "6.4.3";
  };
  faraday = {
    dependencies = ["base64" "faraday-net_http" "ruby2_keywords"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "19p45ryrvxff6ggdj4fq76dk7wlkfgrh474c3kwzdsjx3xpdq8x8";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "2.8.1";
  };
  faraday-http-cache = {
    dependencies = ["faraday"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0qvl49xpl2mwxgcj6aj11qrjk94xrqhbnpl5vp1y2275crnkddv4";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "2.5.0";
  };
  faraday-net_http = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "13byv3mp1gsjyv8k0ih4612y6vw5kqva6i03wcg4w2fqpsd950k8";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "3.0.2";
  };
  faraday-net_http_persistent = {
    dependencies = ["faraday" "net-http-persistent"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "02yydasm9qlq59dnj3dldaqd0xidxyx59pnr2iqygnjn7yqj05xl";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "2.1.0";
  };
  faraday-retry = {
    dependencies = ["faraday"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1ia19zgni6cw96rvsr0s004vjs9m2r6la4s00zcff36xaia4m0l0";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "2.2.0";
  };
  ferrum = {
    dependencies = ["addressable" "concurrent-ruby" "webrick" "websocket-driver"];
    groups = ["default" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "09f72adiwg80kj8zmawr6sb0bkdd6gf0mwg54ncpvy4vs91gk8z9";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "0.14";
  };
  ffi = {
    groups = ["default" "development" "test"];
    platforms = [];
    source = null;
    targets = [{
      remotes = ["https://rubygems.org"];
      sha256 = "04hdrlzyri00lgwi4rh8vzy8z8x789p5gc45sk344ib1fr78g730";
      target = "arm64-darwin";
      targetCPU = "arm64";
      targetOS = "darwin";
      type = "gem";
    } {
      remotes = ["https://rubygems.org"];
      sha256 = "0szml3n6ql6wzl5fq2rcl1w9iksz4zb68p7cbbwkwc5kkp34ikgx";
      target = "x86_64-darwin";
      targetCPU = "x86_64";
      targetOS = "darwin";
      type = "gem";
    } {
      remotes = ["https://rubygems.org"];
      sha256 = "1621lgx1isrwjj4j27lvlxjfd6v3pnq2ahvhn2y6pp8rb6fya58h";
      target = "x86_64-linux-gnu";
      targetCPU = "x86_64";
      targetOS = "linux";
      type = "gem";
    }];
    version = "1.17.0";
  };
  forgery = {
    groups = ["test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1d2myx5c8a0jgsr5jx619ds3xk4xz2js53dgpj51pmbcp9gggm6l";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "0.8.1";
  };
  formatador = {
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1l06bv4avphbdmr1y4g0rqlczr38k6r65b3zghrbj2ynyhm3xqjl";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "1.1.0";
  };
  globalid = {
    dependencies = ["activesupport"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1sbw6b66r7cwdx3jhs46s4lr991969hvigkjpbdl7y3i31qpdgvh";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "1.2.1";
  };
  google-protobuf = {
    dependencies = ["bigdecimal" "rake"];
    groups = ["default"];
    platforms = [];
    source = null;
    targets = [{
      remotes = ["https://rubygems.org"];
      sha256 = "17jxad8c62v92wn0b33ygzqx5ay3xdzq6g6nn342rw67hpb00j8v";
      target = "arm64-darwin";
      targetCPU = "arm64";
      targetOS = "darwin";
      type = "gem";
    } {
      remotes = ["https://rubygems.org"];
      sha256 = "1h3cjaarnhn9idx6101zmgk5nx707al8118rshgr1i771gfxdh3w";
      target = "x86_64-darwin";
      targetCPU = "x86_64";
      targetOS = "darwin";
      type = "gem";
    } {
      remotes = ["https://rubygems.org"];
      sha256 = "1xq6430n0464a8qwpbd16al5ndg3pfph2r2q2nsf9jgvpzvfkjph";
      target = "x86_64-linux";
      targetCPU = "x86_64";
      targetOS = "linux";
      type = "gem";
    }];
    version = "4.27.3";
  };
  googleapis-common-protos-types = {
    dependencies = ["google-protobuf"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0sqmmfdxjp3fy7hzvl35bnd0yb0ds9030np5jqh338qz4w661cap";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "1.15.0";
  };
  govspeak = {
    dependencies = ["actionview" "addressable" "govuk_publishing_components" "htmlentities" "i18n" "kramdown" "nokogiri" "rinku" "sanitize"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0f1v9ialkha26magkzsljxsd5jyfpf32p3i1yp4ip91kb31lgk01";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "8.3.4";
  };
  govuk_app_config = {
    dependencies = ["logstasher" "opentelemetry-exporter-otlp" "opentelemetry-instrumentation-all" "opentelemetry-sdk" "plek" "prometheus_exporter" "puma" "rack-proxy" "sentry-rails" "sentry-ruby" "statsd-ruby"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "14l70nc2nkh5db5zlm8zhi9vny5c2b92adn0zxfmi0kmnwjw2glq";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "9.14.0";
  };
  govuk_design_system_formbuilder = {
    dependencies = ["actionview" "activemodel" "activesupport" "html-attributes-utils"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0r317ss4qfkcb5sq38ni86pc85qmxjbs8rmnkd7hcp2q36zkz7j6";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "5.4.1";
  };
  govuk_personalisation = {
    dependencies = ["plek" "rails"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0xs6miyx0kmb4gkl5h7ajh5qn4955bqzcciddy845m013vx0y05i";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "0.16.0";
  };
  govuk_publishing_components = {
    dependencies = ["govuk_app_config" "govuk_personalisation" "kramdown" "plek" "rails" "rouge" "sprockets" "sprockets-rails"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1x9m18pw2acanwhl8gsimk2a74wx5swchpb7n69w4l8mjmsivffv";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "41.0.0";
  };
  guard = {
    dependencies = ["formatador" "listen" "lumberjack" "nenv" "notiffany" "pry" "shellany" "thor"];
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "02bwv3396cqsn980a3yzh6l3xm8f7rqjfnphssrajf6m4cxkv2d3";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "2.18.1";
  };
  guard-compat = {
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1zj6sr1k8w59mmi27rsii0v8xyy2rnsi09nqvwpgj1q10yq1mlis";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "1.2.1";
  };
  guard-rspec = {
    dependencies = ["guard" "guard-compat" "rspec"];
    groups = ["development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1jkm5xp90gm4c5s51pmf92i9hc10gslwwic6mvk72g0yplya0yx4";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "4.7.3";
  };
  guard-rubocop = {
    dependencies = ["guard" "rubocop"];
    groups = ["development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0lb2fgfac97lvgwqvx2gbcimyvw2a0i76x6yabik3vmmvjbdfh9h";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "1.5.0";
  };
  hashdiff = {
    groups = ["default" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1nynpl0xbj0nphqx1qlmyggq58ms1phf5i03hk64wcc0a17x1m1c";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "1.0.1";
  };
  html-attributes-utils = {
    dependencies = ["activesupport"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "132kwasf3rn29x9zw27xfmk8fvw936bywfw9pr55aknxncvhnkjr";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "1.0.2";
  };
  htmlentities = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1nkklqsn8ir8wizzlakncfv42i32wc0w9hxp00hvdlgjr7376nhj";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "4.3.4";
  };
  i18n = {
    dependencies = ["concurrent-ruby"];
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1ffix518y7976qih9k1lgnc17i3v6yrlh0a3mckpxdb4wc2vrp16";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "1.14.5";
  };
  io-console = {
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "08d2lx42pa8jjav0lcjbzfzmw61b8imxr9041pva8xzqabrczp7h";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "0.7.2";
  };
  irb = {
    dependencies = ["rdoc" "reline"];
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "05g6vpz3997q4j3xhrliswfx3g5flsn5cfn1p1s4h6dx7c0hbn2k";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "1.14.0";
  };
  jaro_winkler = {
    groups = ["default" "development"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "09645h5an19zc1i7wlmixszj8xxqb2zc8qlf8dmx39bxpas1l24b";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "1.6.0";
  };
  jmespath = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1cdw9vw2qly7q7r41s7phnac264rbsdqgj4l0h4nqgbjb157g393";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "1.6.2";
  };
  json = {
    groups = ["default" "development"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0nalhin1gda4v8ybk6lq8f407cgfrj6qzn234yra4ipkmlbfmal6";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "2.6.3";
  };
  kaminari = {
    dependencies = ["activesupport" "kaminari-actionview" "kaminari-activerecord" "kaminari-core"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0gia8irryvfhcr6bsr64kpisbgdbqjsqfgrk12a11incmpwny1y4";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "1.2.2";
  };
  kaminari-actionview = {
    dependencies = ["actionview" "kaminari-core"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "02f9ghl3a9b5q7l079d3yzmqjwkr4jigi7sldbps992rigygcc0k";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "1.2.2";
  };
  kaminari-activerecord = {
    dependencies = ["activerecord" "kaminari-core"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0c148z97s1cqivzbwrak149z7kl1rdmj7dxk6rpkasimmdxsdlqd";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "1.2.2";
  };
  kaminari-core = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1zw3pg6kj39y7jxakbx7if59pl28lhk98fx71ks5lr3hfgn6zliv";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "1.2.2";
  };
  kramdown = {
    dependencies = ["rexml"];
    groups = ["default" "development"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1ic14hdcqxn821dvzki99zhmcy130yhv5fqfffkcf87asv5mnbmn";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "2.4.0";
  };
  kramdown-parser-gfm = {
    dependencies = ["kramdown"];
    groups = ["default" "development"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0a8pb3v951f4x7h968rqfsa19c8arz21zw1vaj42jza22rap8fgv";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "1.1.0";
  };
  language_server-protocol = {
    groups = ["default" "development"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0gvb1j8xsqxms9mww01rmdl78zkd72zgxaap56bhv8j45z05hp1x";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "3.17.0.3";
  };
  launchy = {
    dependencies = ["addressable"];
    groups = ["default" "development"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "06r43899384das2bkbrpsdxsafyyqa94il7111053idfalb4984a";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "2.5.2";
  };
  letter_opener = {
    dependencies = ["launchy"];
    groups = ["development"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1y5d4ip4l12v58bgazadl45iv3a5j7jp2gwg96b6jy378zn42a1d";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "1.8.1";
  };
  listen = {
    dependencies = ["rb-fsevent" "rb-inotify"];
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0rwwsmvq79qwzl6324yc53py02kbrcww35si720490z5w0j497nv";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "3.9.0";
  };
  lograge = {
    dependencies = ["actionpack" "activesupport" "railties" "request_store"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1qcsvh9k4c0cp6agqm9a8m4x2gg7vifryqr7yxkg2x9ph9silds2";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "0.14.0";
  };
  logstash-event = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1bk7fhhryjxp1klr3hq6i6srrc21wl4p980bysjp0w66z9hdr9w9";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "1.2.02";
  };
  logstasher = {
    dependencies = ["activesupport" "request_store"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "00hdrmyn2a0j0yzsqcz92w2wfxiprx3kk6wh46jrsax7v4494ph9";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "2.1.5";
  };
  loofah = {
    dependencies = ["crass" "nokogiri"];
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1zkjqf37v2d7s11176cb35cl83wls5gm3adnfkn2zcc61h3nxmqh";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "2.22.0";
  };
  lumberjack = {
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0v1bqhwphdrs41df6vxdpkwc7gjqdd4svwfbiq19a41l54b9bzmv";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "1.2.10";
  };
  mail = {
    dependencies = ["mini_mime" "net-imap" "net-pop" "net-smtp"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1bf9pysw1jfgynv692hhaycfxa8ckay1gjw5hz3madrbrynryfzc";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "2.8.1";
  };
  marcel = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "190n2mk8m1l708kr88fh6mip9sdsh339d2s6sgrik3sbnvz4jmhd";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "1.0.4";
  };
  matrix = {
    groups = ["default" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1h2cgkpzkh3dd0flnnwfq6f3nl2b1zff9lvqz8xs853ssv5kq23i";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "0.4.2";
  };
  method_source = {
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1pnyh44qycnf9mzi1j6fywd5fkskv3x7nmsqrrws0rjn5dd4ayfp";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "1.0.0";
  };
  mini_mime = {
    groups = ["default" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1vycif7pjzkr29mfk4dlqv3disc5dn0va04lkwajlpr1wkibg0c6";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "1.1.5";
  };
  minitest = {
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0jj629q3vw5yn90q4di4dyb87pil4a8qfm2srhgy5nc8j2n33v1i";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "5.24.1";
  };
  msgpack = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1a5adcb7bwan09mqhj3wi9ib52hmdzmqg7q08pggn3adibyn5asr";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "1.7.2";
  };
  multi_json = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0pb1g1y3dsiahavspyzkdy39j4q377009f6ix0bh1ag4nqw43l0z";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "1.15.0";
  };
  mutex_m = {
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1ma093ayps1m92q845hmpk0dmadicvifkbf05rpq9pifhin0rvxn";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "0.2.0";
  };
  nenv = {
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0r97jzknll9bhd8yyg2bngnnkj8rjhal667n7d32h8h7ny7nvpnr";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "0.3.0";
  };
  net-http-persistent = {
    dependencies = ["connection_pool"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0i1as2lgnw7b4jid0gw5glv5hnxz36nmfsbr9rmxbcap72ijgy03";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "4.0.2";
  };
  net-imap = {
    dependencies = ["date" "net-protocol"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0rc08fxm10vv73bg0nqyp5bdvl4cvzb3y4cdk4kwmxx414zln652";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "0.4.14";
  };
  net-pop = {
    dependencies = ["net-protocol"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1wyz41jd4zpjn0v1xsf9j778qx1vfrl24yc20cpmph8k42c4x2w4";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "0.1.2";
  };
  net-protocol = {
    dependencies = ["timeout"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1a32l4x73hz200cm587bc29q8q9az278syw3x6fkc9d1lv5y0wxa";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "0.2.2";
  };
  net-smtp = {
    dependencies = ["net-protocol"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0amlhz8fhnjfmsiqcjajip57ici2xhw089x7zqyhpk51drg43h2z";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "0.5.0";
  };
  nio4r = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "017nbw87dpr4wyk81cgj8kxkxqgsgblrkxnmmadc77cg9gflrfal";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "2.7.3";
  };
  nokogiri = {
    dependencies = ["racc"];
    groups = ["default" "development" "test"];
    platforms = [];
    source = null;
    targets = [{
      remotes = ["https://rubygems.org"];
      sha256 = "0532vzx4j3jvi4k66avylpfsfw5r7200ppimmmsrzd7d61sh63cm";
      target = "arm64-darwin";
      targetCPU = "arm64";
      targetOS = "darwin";
      type = "gem";
    } {
      remotes = ["https://rubygems.org"];
      sha256 = "0y9jlqb4431i3wcdh0i4lsfi45j7rhdbghv7vw9kshwc6x7gbdbi";
      target = "x86_64-darwin";
      targetCPU = "x86_64";
      targetOS = "darwin";
      type = "gem";
    } {
      remotes = ["https://rubygems.org"];
      sha256 = "15vaia0l9b3aqjcqjqy5qiv9pfwiazrzcyl3yz9bwrh0hzd3i8hc";
      target = "x86_64-linux";
      targetCPU = "x86_64";
      targetOS = "linux";
      type = "gem";
    }];
    version = "1.16.5";
  };
  notiffany = {
    dependencies = ["nenv" "shellany"];
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0f47h3bmg1apr4x51szqfv3rh2vq58z3grh4w02cp3bzbdh6jxnk";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "0.1.3";
  };
  opentelemetry-api = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "08smcww0ayv3xh5bpnx2ih2cw4r48kbb44ww2p3kbfgl0ifpghz1";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "1.3.0";
  };
  opentelemetry-common = {
    dependencies = ["opentelemetry-api"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "160ws06d8mzx3hwjss2i954h8r86dp3sw95k2wrbq81sb121m2gy";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "0.21.0";
  };
  opentelemetry-exporter-otlp = {
    dependencies = ["google-protobuf" "googleapis-common-protos-types" "opentelemetry-api" "opentelemetry-common" "opentelemetry-sdk" "opentelemetry-semantic_conventions"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0saiiaf5bkg95fjcq6asz5w86s6zg76xb0r93dcffhvnz36z0r2v";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "0.28.1";
  };
  opentelemetry-helpers-mysql = {
    dependencies = ["opentelemetry-api" "opentelemetry-common"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1nni39rjqnr29p2zg31g9wyz30kg4vncsp4hf7q87r671fwxm6fd";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "0.1.1";
  };
  opentelemetry-helpers-sql-obfuscation = {
    dependencies = ["opentelemetry-common"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1k4x07chv75ajsaww3jpji9abylz5801ps78ygds7bwsdffx9z3p";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "0.1.1";
  };
  opentelemetry-instrumentation-action_mailer = {
    dependencies = ["opentelemetry-api" "opentelemetry-instrumentation-active_support" "opentelemetry-instrumentation-base"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1afibmwprdiqnkin7lb6zdxng36rqa7qbl5fl9wx0lchpc039zjj";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "0.1.0";
  };
  opentelemetry-instrumentation-action_pack = {
    dependencies = ["opentelemetry-api" "opentelemetry-instrumentation-base" "opentelemetry-instrumentation-rack"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "16nbkayp8jb2zkqj2rmqd4d1mz4wdf0zg6jx8b0vzkf9mxr89py5";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "0.9.0";
  };
  opentelemetry-instrumentation-action_view = {
    dependencies = ["opentelemetry-api" "opentelemetry-instrumentation-active_support" "opentelemetry-instrumentation-base"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "01ylac7wjnmzb3zz3ss9rrsp74ah741mkvxs9i5w6cx20s0pmay0";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "0.7.1";
  };
  opentelemetry-instrumentation-active_job = {
    dependencies = ["opentelemetry-api" "opentelemetry-instrumentation-base"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0qn7szahrb1iwcskq2c5hc7ypazy2l0yjv6r4rv8rn0dqnhmfqs2";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "0.7.4";
  };
  opentelemetry-instrumentation-active_model_serializers = {
    dependencies = ["opentelemetry-api" "opentelemetry-instrumentation-base"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0yw98f8z6k4c8ns7p8ik2dc68p4vbi12xnavzw0vqhlnny4nx0n7";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "0.20.2";
  };
  opentelemetry-instrumentation-active_record = {
    dependencies = ["opentelemetry-api" "opentelemetry-instrumentation-base"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0wjfd1dmfzcnvss2jsnc2s3g6p0wfq5ay3vfnidkmisgyw7fphfk";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "0.7.2";
  };
  opentelemetry-instrumentation-active_support = {
    dependencies = ["opentelemetry-api" "opentelemetry-instrumentation-base"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1q07nn9ipq2yd7xjj24hh00cbvlda269k1l0xfkc8d8iw8mixrsg";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "0.6.0";
  };
  opentelemetry-instrumentation-all = {
    dependencies = ["opentelemetry-instrumentation-active_model_serializers" "opentelemetry-instrumentation-aws_lambda" "opentelemetry-instrumentation-aws_sdk" "opentelemetry-instrumentation-bunny" "opentelemetry-instrumentation-concurrent_ruby" "opentelemetry-instrumentation-dalli" "opentelemetry-instrumentation-delayed_job" "opentelemetry-instrumentation-ethon" "opentelemetry-instrumentation-excon" "opentelemetry-instrumentation-faraday" "opentelemetry-instrumentation-grape" "opentelemetry-instrumentation-graphql" "opentelemetry-instrumentation-gruf" "opentelemetry-instrumentation-http" "opentelemetry-instrumentation-http_client" "opentelemetry-instrumentation-koala" "opentelemetry-instrumentation-lmdb" "opentelemetry-instrumentation-mongo" "opentelemetry-instrumentation-mysql2" "opentelemetry-instrumentation-net_http" "opentelemetry-instrumentation-pg" "opentelemetry-instrumentation-que" "opentelemetry-instrumentation-racecar" "opentelemetry-instrumentation-rack" "opentelemetry-instrumentation-rails" "opentelemetry-instrumentation-rake" "opentelemetry-instrumentation-rdkafka" "opentelemetry-instrumentation-redis" "opentelemetry-instrumentation-resque" "opentelemetry-instrumentation-restclient" "opentelemetry-instrumentation-ruby_kafka" "opentelemetry-instrumentation-sidekiq" "opentelemetry-instrumentation-sinatra" "opentelemetry-instrumentation-trilogy"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1svld9vc7ykb4fgimgkdb6cnmcrxiymjl3h4l49d3ll53vc91ygl";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "0.62.1";
  };
  opentelemetry-instrumentation-aws_lambda = {
    dependencies = ["opentelemetry-api" "opentelemetry-instrumentation-base"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0rrw5s2nl5pkrx05p96jgqn5zqwwczyin3b3mmd07rs64w1bkpl9";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "0.1.1";
  };
  opentelemetry-instrumentation-aws_sdk = {
    dependencies = ["opentelemetry-api" "opentelemetry-instrumentation-base"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1fxk5jaliz93njgfmbl5ygsbzbwqbh0g48w4ar905xxsfg1dl18q";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "0.5.4";
  };
  opentelemetry-instrumentation-base = {
    dependencies = ["opentelemetry-api" "opentelemetry-common" "opentelemetry-registry"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0w17bfxvix8imskknsr80z4wsr0nkm12bf12pc7ybvahc94a5k6h";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "0.22.5";
  };
  opentelemetry-instrumentation-bunny = {
    dependencies = ["opentelemetry-api" "opentelemetry-instrumentation-base"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1ajvsri8qr98ln0jiz51amdfxwayn2m63qcpxi79pbjc0gilivl6";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "0.21.4";
  };
  opentelemetry-instrumentation-concurrent_ruby = {
    dependencies = ["opentelemetry-api" "opentelemetry-instrumentation-base"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1khlhzwb37mqnzr1vr49ljhi4bplmq9w8ndm0k8xbfsr8h8wivq4";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "0.21.4";
  };
  opentelemetry-instrumentation-dalli = {
    dependencies = ["opentelemetry-api" "opentelemetry-instrumentation-base"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "15q65w7apq5lp9x86slypaikrssp7vq5y629znirxvkw14wp9c47";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "0.25.4";
  };
  opentelemetry-instrumentation-delayed_job = {
    dependencies = ["opentelemetry-api" "opentelemetry-instrumentation-base"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0vrbi9nk09axp8j66f4vb2hmvn8kbip7bl6lrmvznq44dvnj1m8w";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "0.22.4";
  };
  opentelemetry-instrumentation-ethon = {
    dependencies = ["opentelemetry-api" "opentelemetry-instrumentation-base"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1s6ya4sr4w492qbd16b33qpk52wf3903l2ns6camv79kq1h7vahr";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "0.21.8";
  };
  opentelemetry-instrumentation-excon = {
    dependencies = ["opentelemetry-api" "opentelemetry-instrumentation-base"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "14g6dvk31kz9v9qbr2w6ggxk96v3kaadm8wvnw3qsrsc4pd9ycns";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "0.22.4";
  };
  opentelemetry-instrumentation-faraday = {
    dependencies = ["opentelemetry-api" "opentelemetry-instrumentation-base"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0np6wnckn12df6mwcr695fvjy3x2s6541ywr7ahw8a8dszs0qjsh";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "0.24.6";
  };
  opentelemetry-instrumentation-grape = {
    dependencies = ["opentelemetry-api" "opentelemetry-instrumentation-base" "opentelemetry-instrumentation-rack"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1dhpapza8qw8clfp7pri6r6sbibrx07sj7xfk3myivmp05rms8m1";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "0.2.0";
  };
  opentelemetry-instrumentation-graphql = {
    dependencies = ["opentelemetry-api" "opentelemetry-instrumentation-base"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0v6w0b3q0li5cq0xmc42ngqk9ahx60n5q31alka36ds4inxcrky2";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "0.28.4";
  };
  opentelemetry-instrumentation-gruf = {
    dependencies = ["opentelemetry-api" "opentelemetry-instrumentation-base"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0if57lll1f29pl56s8qbm159f97b7mhrcbjka5r7wq080lv1h2sf";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "0.2.1";
  };
  opentelemetry-instrumentation-http = {
    dependencies = ["opentelemetry-api" "opentelemetry-instrumentation-base"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "05mrlg8msp59bagpc18ycr9333760kqp780gw8fgqn1798dl02qr";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "0.23.4";
  };
  opentelemetry-instrumentation-http_client = {
    dependencies = ["opentelemetry-api" "opentelemetry-instrumentation-base"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0g6f5zv0bq585ppgzhm6acrpkz32j1h7zyrcy1r8n3ha41daip1z";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "0.22.7";
  };
  opentelemetry-instrumentation-koala = {
    dependencies = ["opentelemetry-api" "opentelemetry-instrumentation-base"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1i1vpy7h5gq9c5rs5ann2i5h5m18y9pzvdxjmpzd575y34d92kdl";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "0.20.5";
  };
  opentelemetry-instrumentation-lmdb = {
    dependencies = ["opentelemetry-api" "opentelemetry-instrumentation-base"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "00m5ml5ixv1g8gmpqcqsrw8c72mf70rfbrd8cjdaq9bhdwan0v9p";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "0.22.3";
  };
  opentelemetry-instrumentation-mongo = {
    dependencies = ["opentelemetry-api" "opentelemetry-instrumentation-base"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1lcrsrjszj908qpl22p3r6bpl69xajyfcasgygr8b75lx1hfdakp";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "0.22.4";
  };
  opentelemetry-instrumentation-mysql2 = {
    dependencies = ["opentelemetry-api" "opentelemetry-helpers-mysql" "opentelemetry-helpers-sql-obfuscation" "opentelemetry-instrumentation-base"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1sggbiwdycq9911lgvd6wfklkn204ppjyfcn4xqb64sxbqxqdmv6";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "0.27.2";
  };
  opentelemetry-instrumentation-net_http = {
    dependencies = ["opentelemetry-api" "opentelemetry-instrumentation-base"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1l26f8sqsjjcc72a5xr9as3gibm4sgj8n004y15i5vbvdgzjfx60";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "0.22.7";
  };
  opentelemetry-instrumentation-pg = {
    dependencies = ["opentelemetry-api" "opentelemetry-helpers-sql-obfuscation" "opentelemetry-instrumentation-base"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1zxx75rd2fv82rzc7nw03x5ba7pmbnw32jns566n6wqvzsn3x2cr";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "0.27.4";
  };
  opentelemetry-instrumentation-que = {
    dependencies = ["opentelemetry-api" "opentelemetry-instrumentation-base"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0yn022g9dziz5cwdvys7n4s9bmn5q9v6aygbv0wymxlxvh8c4f7s";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "0.8.3";
  };
  opentelemetry-instrumentation-racecar = {
    dependencies = ["opentelemetry-api" "opentelemetry-instrumentation-base"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0qz159bjzlmygga8gpngk7zdq08a5fmn8zwhjh1wz1w4vcrzy1f6";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "0.3.4";
  };
  opentelemetry-instrumentation-rack = {
    dependencies = ["opentelemetry-api" "opentelemetry-instrumentation-base"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1dmfxcc2xz2qa4zp0sks5zrqcfr4fbpbc9xdgvcv8ys0ipf7pwn0";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "0.24.6";
  };
  opentelemetry-instrumentation-rails = {
    dependencies = ["opentelemetry-api" "opentelemetry-instrumentation-action_mailer" "opentelemetry-instrumentation-action_pack" "opentelemetry-instrumentation-action_view" "opentelemetry-instrumentation-active_job" "opentelemetry-instrumentation-active_record" "opentelemetry-instrumentation-active_support" "opentelemetry-instrumentation-base"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0k1wapaddc7kyzcjdzgw5wrh6m6ijw8ywq8kwxxi9ajybnyzdb05";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "0.31.1";
  };
  opentelemetry-instrumentation-rake = {
    dependencies = ["opentelemetry-api" "opentelemetry-instrumentation-base"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0840gnlr90nbl430yc72czn26bngdp94v4adz7q9ph3pmdm8mppv";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "0.2.2";
  };
  opentelemetry-instrumentation-rdkafka = {
    dependencies = ["opentelemetry-api" "opentelemetry-instrumentation-base"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1pmx5kz9cz7x8i8f45jivibndqxip542p7ik764pb3ylwraky4n6";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "0.4.8";
  };
  opentelemetry-instrumentation-redis = {
    dependencies = ["opentelemetry-api" "opentelemetry-instrumentation-base"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1qrgnk2x64sks9gqb7fycfa6sass6ddqzh5dms4hdbz1bzag581f";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "0.25.7";
  };
  opentelemetry-instrumentation-resque = {
    dependencies = ["opentelemetry-api" "opentelemetry-instrumentation-base"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "04d03zvmm3d9h6qvwdpy34lrywzphhs7fc2xgmad5zs847zb0jvy";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "0.5.2";
  };
  opentelemetry-instrumentation-restclient = {
    dependencies = ["opentelemetry-api" "opentelemetry-instrumentation-base"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0h99imc6s2rnpmkx2zghidbp6ggmz85wpicldmwph7y88pq29v8l";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "0.22.7";
  };
  opentelemetry-instrumentation-ruby_kafka = {
    dependencies = ["opentelemetry-api" "opentelemetry-instrumentation-base"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1mh7nf99k7hnyaizw4bs8g25sj984d4vjsb3dp81ymf8fb07m5fd";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "0.21.3";
  };
  opentelemetry-instrumentation-sidekiq = {
    dependencies = ["opentelemetry-api" "opentelemetry-instrumentation-base"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0cfzw1avv52idxvq02y95g3byxsswccck78zch5hmnnzvp5f59nn";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "0.25.7";
  };
  opentelemetry-instrumentation-sinatra = {
    dependencies = ["opentelemetry-api" "opentelemetry-instrumentation-base" "opentelemetry-instrumentation-rack"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0fvzxr49fpqdfmv7xalivziji1jdggyqq5fw773pqn01svlkb8qn";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "0.24.1";
  };
  opentelemetry-instrumentation-trilogy = {
    dependencies = ["opentelemetry-api" "opentelemetry-helpers-mysql" "opentelemetry-helpers-sql-obfuscation" "opentelemetry-instrumentation-base" "opentelemetry-semantic_conventions"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0lqkkn57b3bq518q5k3nvc4kplgkjcb2jw3r6kb22gisi3x5s8k7";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "0.59.3";
  };
  opentelemetry-registry = {
    dependencies = ["opentelemetry-api"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1pw87n9vpv40hf7f6gyl2vvbl11hzdkv4psbbv3x23jvccs8593k";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "0.3.1";
  };
  opentelemetry-sdk = {
    dependencies = ["opentelemetry-api" "opentelemetry-common" "opentelemetry-registry" "opentelemetry-semantic_conventions"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0div7n5wac7x1l9fwdpb3bllw18cns93c7xccy27r4gmvv02f46s";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "1.5.0";
  };
  opentelemetry-semantic_conventions = {
    dependencies = ["opentelemetry-api"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "10anxw736pg85nw8vb11xnr5faq7qj8a1d8c62qbpjs6m0izi77y";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "1.10.1";
  };
  parallel = {
    groups = ["default" "development"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0jcc512l38c0c163ni3jgskvq1vc3mr8ly5pvjijzwvfml9lf597";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "1.23.0";
  };
  parser = {
    dependencies = ["ast" "racc"];
    groups = ["default" "development"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1swigds85jddb5gshll1g8lkmbcgbcp9bi1d4nigwvxki8smys0h";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "3.2.2.3";
  };
  plek = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1zb91myghjwf72y78p91kc96yp5wya3i8p2nnvr0l8dra8hzli51";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "5.1.0";
  };
  prometheus_exporter = {
    dependencies = ["webrick"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "06ydq9d09w8m1vk6jp0gy7ab03nvlcf28hi07arpq6x5cxd2aljk";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "2.1.1";
  };
  pry = {
    dependencies = ["coderay" "method_source"];
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0k9kqkd9nps1w1r1rb7wjr31hqzkka2bhi8b518x78dcxppm9zn4";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "0.14.2";
  };
  pry-byebug = {
    dependencies = ["byebug" "pry"];
    groups = ["development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1y41al94ks07166qbp2200yzyr5y60hm7xaiw4lxpgsm4b1pbyf8";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "3.10.1";
  };
  pry-rails = {
    dependencies = ["pry"];
    groups = ["development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1cf4ii53w2hdh7fn8vhqpzkymmchjbwij4l3m7s6fsxvb9bn51j6";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "0.3.9";
  };
  psych = {
    dependencies = ["stringio"];
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0s5383m6004q76xm3lb732bp4sjzb6mxb6rbgn129gy2izsj4wrk";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "5.1.2";
  };
  public_suffix = {
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1vb6f3v8q9m67xmbdl4vbmxis53a7igci4blg561jdfp613cf3i5";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "5.1.1";
  };
  puma = {
    dependencies = ["nio4r"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0i2vaww6qcazj0ywva1plmjnj6rk23b01szswc5jhcq7s2cikd1y";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "6.4.2";
  };
  racc = {
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0byn0c9nkahsl93y9ln5bysq4j31q8xkf2ws42swighxd4lnjzsa";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "1.8.1";
  };
  rack = {
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0hj0rkw2z9r1lcg2wlrcld2n3phwrcgqcp7qd1g9a7hwgalh2qzx";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "2.2.9";
  };
  rack-cors = {
    dependencies = ["rack"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "06ysmn14pdf2wyr7agm0qvvr9pzcgyf39w4yvk2n05w9k4alwpa1";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "2.0.2";
  };
  rack-proxy = {
    dependencies = ["rack"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "12jw7401j543fj8cc83lmw72d8k6bxvkp9rvbifi88hh01blnsj4";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "0.7.7";
  };
  rack-session = {
    dependencies = ["rack"];
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0xhxhlsz6shh8nm44jsmd9276zcnyzii364vhcvf0k8b8bjia8d0";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "1.0.2";
  };
  rack-test = {
    dependencies = ["rack"];
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1ysx29gk9k14a14zsp5a8czys140wacvp91fja8xcja0j1hzqq8c";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "2.1.0";
  };
  rackup = {
    dependencies = ["rack" "webrick"];
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1wbr03334ba9ilcq25wh9913xciwj0j117zs60vsqm0zgwdkwpp9";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "1.0.0";
  };
  rails = {
    dependencies = ["actioncable" "actionmailbox" "actionmailer" "actionpack" "actiontext" "actionview" "activejob" "activemodel" "activerecord" "activestorage" "activesupport" "railties"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1bd6b970kwz9l23ffwg77n424gyhqqm31f493vf43rjfyyfwlzrs";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "7.1.3.4";
  };
  rails-controller-testing = {
    dependencies = ["actionpack" "actionview" "activesupport"];
    groups = ["test"];
    platforms = [];
    source = {
      fetchSubmodules = false;
      rev = "c203673f8011a7cdc2a8edf995ae6b3eec3417ca";
      sha256 = "1ygfr32sc69488rxj8h76rkyq0bsq36wndcfh4fp5m31brbi33br";
      type = "git";
      url = "https://github.com/rails/rails-controller-testing.git";
    };
    targets = [];
    version = "1.0.5";
  };
  rails-dom-testing = {
    dependencies = ["activesupport" "minitest" "nokogiri"];
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0fx9dx1ag0s1lr6lfr34lbx5i1bvn3bhyf3w3mx6h7yz90p725g5";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "2.2.0";
  };
  rails-html-sanitizer = {
    dependencies = ["loofah" "nokogiri"];
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1pm4z853nyz1bhhqr7fzl44alnx4bjachcr6rh6qjj375sfz3sc6";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "1.6.0";
  };
  railties = {
    dependencies = ["actionpack" "activesupport" "irb" "rackup" "rake" "thor" "zeitwerk"];
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1z0slb2dlwrwgqijbk37hl4r9bh4h8vzcyswz6a9srl8lzrljq3c";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "7.1.3.4";
  };
  rainbow = {
    groups = ["default" "development"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0smwg4mii0fm38pyb5fddbmrdpifwv22zv3d3px2xx497am93503";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "3.1.1";
  };
  rake = {
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "17850wcwkgi30p7yqh60960ypn7yibacjjha0av78zaxwvd3ijs6";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "13.2.1";
  };
  rb-fsevent = {
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1zmf31rnpm8553lqwibvv3kkx0v7majm1f341xbxc0bk5sbhp423";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "0.11.2";
  };
  rb-inotify = {
    dependencies = ["ffi"];
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0vmy8xgahixcz6hzwy4zdcyn2y6d6ri8dqv5xccgzc1r292019x0";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "0.11.1";
  };
  rbs = {
    groups = ["default" "development"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0dgj5n7rj83981fvrhswfwsh88x42p7r00nvd80hkxmdcjvda2h6";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "2.8.4";
  };
  rdoc = {
    dependencies = ["psych"];
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0ygk2zk0ky3d88v3ll7qh6xqvbvw5jin0hqdi1xkv1dhaw7myzdi";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "6.7.0";
  };
  redis = {
    dependencies = ["redis-client"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1n7k4sgx5vzsigp8c15flz4fclqy4j2a33vim7b2c2w5jyjhwxrv";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "5.0.8";
  };
  redis-client = {
    dependencies = ["connection_pool"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1g096wwj1l1mfbyq5p01pw0cjqk4hmdci4zyzyjwh0h2ycyks8kg";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "0.17.1";
  };
  regexp_parser = {
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "136br91alxdwh1s85z912dwz23qlhm212vy6i3wkinz3z8mkxxl3";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "2.8.1";
  };
  reline = {
    dependencies = ["io-console"];
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0y6kyz7kcilwdpfy3saqfgnar38vr5ys9sp40ndffy6h1znxfbax";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "0.5.9";
  };
  request_store = {
    dependencies = ["rack"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1jw89j9s5p5cq2k7ffj5p4av4j4fxwvwjs1a4i9g85d38r9mvdz1";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "1.7.0";
  };
  reverse_markdown = {
    dependencies = ["nokogiri"];
    groups = ["default" "development"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0087vhw5ik50lxvddicns01clkx800fk5v5qnrvi3b42nrk6885j";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "2.1.1";
  };
  rexml = {
    dependencies = ["strscan"];
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0lavf9ki8ji8q3gd79b1slbxvbky4pvwb7i9g19lgy3id8kpd4ga";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "3.3.6";
  };
  rinku = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0zcdha17s1wzxyc5814j6319wqg33jbn58pg6wmxpws36476fq4b";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "2.0.6";
  };
  rouge = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "072qvvrcqj0yfr3b0j932mlhvn41i38bq37z7z07i3ikagndkqwy";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "4.3.0";
  };
  routing-filter = {
    dependencies = ["actionpack" "activesupport"];
    groups = ["default"];
    platforms = [];
    source = {
      fetchSubmodules = false;
      rev = "3efb9d3cf4b32c976295bb4ed3473c0cce1c1241";
      sha256 = "0r61lf71h76yhfwl3b1kycwrk192n2nhqjz25m6fvp3y6pdf4py8";
      type = "git";
      url = "https://github.com/trade-tariff/routing-filter.git";
    };
    targets = [];
    version = "1.0.0";
  };
  rspec = {
    dependencies = ["rspec-core" "rspec-expectations" "rspec-mocks"];
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "171rc90vcgjl8p1bdrqa92ymrj8a87qf6w20x05xq29mljcigi6c";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "3.12.0";
  };
  rspec-core = {
    dependencies = ["rspec-support"];
    groups = ["default" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0l95bnjxdabrn79hwdhn2q1n7mn26pj7y1w5660v5qi81x458nqm";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "3.12.2";
  };
  rspec-expectations = {
    dependencies = ["diff-lcs" "rspec-support"];
    groups = ["default" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "05j44jfqlv7j2rpxb5vqzf9hfv7w8ba46wwgxwcwd8p0wzi1hg89";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "3.12.3";
  };
  rspec-mocks = {
    dependencies = ["diff-lcs" "rspec-support"];
    groups = ["default" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1gq7gviwpck7fhp4y5ibljljvxgjklza18j62qf6zkm2icaa8lfy";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "3.12.6";
  };
  rspec-rails = {
    dependencies = ["actionpack" "activesupport" "railties" "rspec-core" "rspec-expectations" "rspec-mocks" "rspec-support"];
    groups = ["test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1dpmbq2awsjiwn300cafp9fbvv86dl7zrb760anhmm1qw8yzg1my";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "6.1.0";
  };
  rspec-support = {
    groups = ["default" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1ky86j3ksi26ng9ybd7j0qsdf1lpr8mzrmn98yy9gzv801fvhsgr";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "3.12.1";
  };
  rspec_junit_formatter = {
    dependencies = ["rspec-core"];
    groups = ["test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "059bnq1gcwl9g93cqf13zpz38zk7jxaa43anzz06qkmfwrsfdpa0";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "0.6.0";
  };
  rubocop = {
    dependencies = ["json" "language_server-protocol" "parallel" "parser" "rainbow" "regexp_parser" "rexml" "rubocop-ast" "ruby-progressbar" "unicode-display_width"];
    groups = ["default" "development"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "17c94wl2abqzf4fj469mdxzap1sd3410x421nl6mh2w49jsgvpki";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "1.55.0";
  };
  rubocop-ast = {
    dependencies = ["parser"];
    groups = ["default" "development"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "188bs225kkhrb17dsf3likdahs2p1i1sqn0pr3pvlx50g6r2mnni";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "1.29.0";
  };
  rubocop-capybara = {
    dependencies = ["rubocop"];
    groups = ["default" "development"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "01fn05a87g009ch1sh00abdmgjab87i995msap26vxq1a5smdck6";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "2.18.0";
  };
  rubocop-factory_bot = {
    dependencies = ["rubocop"];
    groups = ["default" "development"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0kqchl8f67k2g56sq2h1sm2wb6br5gi47s877hlz94g5086f77n1";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "2.23.1";
  };
  rubocop-govuk = {
    dependencies = ["rubocop" "rubocop-ast" "rubocop-rails" "rubocop-rake" "rubocop-rspec"];
    groups = ["development"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0dxg7j28qbpr6a5bz99gv1scxjriv1y6ni5ng8xg0qlszl68bwqz";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "4.12.0";
  };
  rubocop-rails = {
    dependencies = ["activesupport" "rack" "rubocop"];
    groups = ["default" "development"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "05r46ds0dm44fb4p67hbz721zck8mdwblzssz2y25yh075hvs36j";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "2.20.2";
  };
  rubocop-rake = {
    dependencies = ["rubocop"];
    groups = ["default" "development"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1nyq07sfb3vf3ykc6j2d5yq824lzq1asb474yka36jxgi4hz5djn";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "0.6.0";
  };
  rubocop-rspec = {
    dependencies = ["rubocop" "rubocop-capybara" "rubocop-factory_bot"];
    groups = ["default" "development"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "00rsflhijcr0q838fgbdmk7knm5kcjpimn6x0k9qmiw15hi96x1d";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "2.22.0";
  };
  ruby-progressbar = {
    groups = ["default" "development"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0cwvyb7j47m7wihpfaq7rc47zwwx9k4v7iqd9s1xch5nm53rrz40";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "1.13.0";
  };
  ruby2_keywords = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1vz322p8n39hz3b4a9gkmz9y7a5jaz41zrm2ywf31dvkqm03glgz";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "0.0.5";
  };
  sanitize = {
    dependencies = ["crass" "nokogiri"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1c9j1rwdp87k7b7mawf8agpdycdr2dsl2wvjipmcy1c55kllp2qp";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "6.1.2";
  };
  semantic_range = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1dlp97vg95plrsaaqj7x8l7z9vsjbhnqk4rw1l30gy26lmxpfrih";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "3.0.0";
  };
  sentry-rails = {
    dependencies = ["railties" "sentry-ruby"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0ncl8br0k6fas4n6c4xw4wr59kq5s2liqn1s4790m73k5p272xq1";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "5.17.3";
  };
  sentry-ruby = {
    dependencies = ["bigdecimal" "concurrent-ruby"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1z5v5zzasy04hbgxbj9n8bb39ayllvps3snfgbc5rydh1d5ilyb1";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "5.17.3";
  };
  shellany = {
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1ryyzrj1kxmnpdzhlv4ys3dnl2r5r3d2rs2jwzbnd1v96a8pl4hf";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "0.0.1";
  };
  shoulda-matchers = {
    dependencies = ["activesupport"];
    groups = ["test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1pfq0w167v4055k0km64sxik1qslhsi32wl2jlidmfzkqmcw00m7";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "6.2.0";
  };
  simplecov = {
    dependencies = ["docile" "simplecov-html" "simplecov_json_formatter"];
    groups = ["test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "198kcbrjxhhzca19yrdcd6jjj9sb51aaic3b0sc3pwjghg3j49py";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "0.22.0";
  };
  simplecov-html = {
    groups = ["default" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0yx01bxa8pbf9ip4hagqkp5m0mqfnwnw2xk8kjraiywz4lrss6jb";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "0.12.3";
  };
  simplecov_json_formatter = {
    groups = ["default" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0a5l0733hj7sk51j81ykfmlk2vd5vaijlq9d5fn165yyx3xii52j";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "0.1.4";
  };
  solargraph = {
    dependencies = ["backport" "benchmark" "diff-lcs" "e2mmap" "jaro_winkler" "kramdown" "kramdown-parser-gfm" "parser" "rbs" "reverse_markdown" "rubocop" "thor" "tilt" "yard"];
    groups = ["development"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0qbjgsrlrwvbywzi0shf3nmfhb52y5fmp9al9nk7c4qqwxyhz397";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "0.50.0";
  };
  sprockets = {
    dependencies = ["concurrent-ruby" "rack"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "15rzfzd9dca4v0mr0bbhsbwhygl0k9l24iqqlx0fijig5zfi66wm";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "4.2.1";
  };
  sprockets-rails = {
    dependencies = ["actionpack" "activesupport" "sprockets"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "17hiqkdpcjyyhlm997mgdcr45v35j5802m5a979i5jgqx5n8xs59";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "3.5.2";
  };
  statsd-ruby = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "028136c463nbravckxb1qi5c5nnv9r6vh2cyhiry423lac4xz79n";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "1.5.0";
  };
  stringio = {
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "07mfqb40b2wh53k33h91zva78f9zwcdnl85jiq74wnaw2wa6wiak";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "3.1.1";
  };
  strscan = {
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0mamrl7pxacbc79ny5hzmakc9grbjysm3yy6119ppgsg44fsif01";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "3.1.0";
  };
  thor = {
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1vq1fjp45az9hfp6fxljhdrkv75cvbab1jfrwcw738pnsiqk8zps";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "1.3.1";
  };
  tilt = {
    groups = ["default" "development"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0kds7wkxmb038cwp6ravnwn8k65ixc68wpm8j5jx5bhx8ndg4x6z";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "2.4.0";
  };
  timeout = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "16mvvsmx90023wrhf8dxc1lpqh0m8alk65shb7xcya6a9gflw7vg";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "0.4.1";
  };
  tzinfo = {
    dependencies = ["concurrent-ruby"];
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "16w2g84dzaf3z13gxyzlzbf748kylk5bdgg3n1ipvkvvqy685bwd";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "2.0.6";
  };
  unicode-display_width = {
    groups = ["default" "development"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1gi82k102q7bkmfi7ggn9ciypn897ylln1jk9q67kjhr39fj043a";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "2.4.2";
  };
  vcr = {
    groups = ["test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "02j9z7yapninfqwsly4l65596zhv2xqyfb91p9vkakwhiyhajq7r";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "6.2.0";
  };
  web-console = {
    dependencies = ["actionview" "activemodel" "bindex" "railties"];
    groups = ["development"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "087y4byl2s3fg0nfhix4s0r25cv1wk7d2j8n5324waza21xg7g77";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "4.2.1";
  };
  webmock = {
    dependencies = ["addressable" "crack" "hashdiff"];
    groups = ["test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0vfispr7wd2p1fs9ckn1qnby1yyp4i1dl7qz8n482iw977iyxrza";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "3.19.1";
  };
  webpacker = {
    dependencies = ["activesupport" "rack-proxy" "railties" "semantic_range"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0fh4vijqiq1h7w28llk67y9csc0m4wkdivrsl4fsxg279v6j5z3i";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "5.4.4";
  };
  webrick = {
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "13qm7s0gr2pmfcl7dxrmq38asaza4w0i2n9my4yzs499j731wh8r";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "1.8.1";
  };
  websocket-driver = {
    dependencies = ["websocket-extensions"];
    groups = ["default" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1nyh873w4lvahcl8kzbjfca26656d5c6z3md4sbqg5y1gfz0157n";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "0.7.6";
  };
  websocket-extensions = {
    groups = ["default" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0hc2g9qps8lmhibl5baa91b4qx8wqw872rgwagml78ydj8qacsqw";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "0.1.5";
  };
  wizard_steps = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "19kd5z6909p31798jb2qmpjwlyxcmhm5qni7dajjkrqwpx41sg46";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "0.1.4";
  };
  xpath = {
    dependencies = ["nokogiri"];
    groups = ["default" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0bh8lk9hvlpn7vmi6h4hkcwjzvs2y0cmkk3yjjdr8fxvj6fsgzbd";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "3.2.0";
  };
  yajl-ruby = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1lni4jbyrlph7sz8y49q84pb0sbj82lgwvnjnsiv01xf26f4v5wc";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "1.4.3";
  };
  yard = {
    groups = ["default" "development"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "14k9lb9a60r9z2zcqg08by9iljrrgjxdkbd91gw17rkqkqwi1sd6";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "0.9.37";
  };
  zeitwerk = {
    groups = ["default" "development" "test"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1b1azc3qlyzlnld4d5yav9j13dlqlyygnml5qf4gqpzaj861d588";
      target = "ruby";
      type = "gem";
    };
    targets = [];
    version = "2.6.17";
  };
}
