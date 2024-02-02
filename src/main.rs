use xcb::x;

fn main() {
    let (connection, screen_num) = xcb::Connection::connect(None).unwrap();

    let root = connection
        .get_setup()
        .roots()
        .nth(screen_num as usize)
        .unwrap()
        .root();

    loop {
        let status = format!("{}", chrono::Local::now().format("%a %d/%m/%Y %T"));

        connection.send_request(&x::ChangeProperty {
            mode: x::PropMode::Replace,
            window: root,
            property: x::ATOM_WM_NAME,
            r#type: x::ATOM_STRING,
            data: status.as_bytes(),
        });

        connection.flush().unwrap();
        std::thread::sleep(std::time::Duration::from_secs(1));
    }
}
