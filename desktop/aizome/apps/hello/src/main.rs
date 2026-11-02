use aizome_kit::prelude::*;
use aizome_kit::column;

#[derive(Default)]

struct Hello;

#[derive(Clone, Debug)]

enum Msg {}

impl Program for Hello {
    type Msg = Msg;

    fn info(&self) -> AppInfo {

        AppInfo::new("org.aizome.Hello", "Hello", "Hello World",
        )
    }

    fn launched(&mut self, cx: &mut Cx<Msg>) {
        cx.open_window(WindowSpec::new("Hello"));
    }

    fn update(&mut self, msg:Msg, _cx: &mut Cx<Msg>) {
        match msg {}
    }

    fn view(&self, _window:WindowKey) -> Element<Msg> {
        column! [
            text("Hello World").size(20.0),
            text("This is a simple example of an Aizome application.")
              .role(Role::Text2),
        ] .into()
    }
}

fn main() {
    aizome_kit::run(Hello);
}
