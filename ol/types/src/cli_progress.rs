//! standardize cli progress bars in 0L tools
use indicatif::ProgressStyle;

/// standard cli progress bars etc. for 0L tools
pub struct OLProgress;

impl OLProgress {
  /// detailed bar
  pub fn bar() -> ProgressStyle {
    ProgressStyle::with_template(
        "{msg} {spinner} [{elapsed_precise}] [{bar:50.green/blue}] ({pos}/{len}, ETA {eta})",
    )
    .unwrap()
  }
  /// who knows how long this will take
    pub fn spinner() -> ProgressStyle {
        ProgressStyle::with_template("{msg} {spinner:.blue}")
        .unwrap()
        // For more spinners check out the cli-spinners project:
        // https://github.com/sindresorhus/cli-spinners/blob/master/spinners.json
        .tick_strings(&[
          "     ",
          ".    ",
          "..   ",
          "...  ",
          ".... ",
          ".....",
          "......",
          " .....",
          "  ....",
          "   ...",
          "    ..",
          "     .",  
        ])
  }

  /// For special occasions. Don't overuse it :)
  pub fn fun() -> ProgressStyle {
        ProgressStyle::with_template("Carpe Diem: {msg} {spinner:.blue}")
        .unwrap()
        // For more spinners check out the cli-spinners project:
        // https://github.com/sindresorhus/cli-spinners/blob/master/spinners.json
        .tick_strings(&[
          "🤜\u{3000}\u{3000}  \u{3000}\u{3000}🤛 ",
          "\u{3000}🤜\u{3000}  \u{3000}🤛\u{3000} ",
          "\u{3000}\u{3000} 🤜🤛 \u{3000}\u{3000} ",
          "\u{3000}\u{3000}🤜✨🤛\u{3000}\u{3000} ",
          "\u{3000}\u{3000}✨✊🌞✨\u{3000}\u{3000} ",
          "\u{3000}✨\u{3000}✊🌞\u{3000}✨\u{3000} ",
          "✨\u{3000}\u{3000}✊🌞\u{3000}\u{3000}✨ ",        
        ])
  }


}


#[test]

fn progress() {
  use indicatif::ProgressIterator;
  let a = 0..50;

  // let ps = OLProgress::bar();
  let wait = core::time::Duration::from_millis(500);
  a.clone().progress_with_style(OLProgress::bar()).with_message("message").for_each(|_|{
    
    std::thread::sleep(wait);
  });

  a.clone().progress_with_style(OLProgress::spinner()).with_message("message").for_each(|_|{
    std::thread::sleep(wait);
  });

  a.progress_with_style(OLProgress::fun()).with_message("message").for_each(|_|{
    std::thread::sleep(wait);
  });

}