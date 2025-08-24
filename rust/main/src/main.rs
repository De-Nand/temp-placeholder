#[link(name = "SDL3")]
unsafe extern "C" {
    fn SDL_INIT(x: u32) -> bool;
}

fn main() {
    //unsafe {SDL_INIT(0x00000020);}
    unsafe {SDL_INIT(0);}
    println!("Hello, world!");
}
