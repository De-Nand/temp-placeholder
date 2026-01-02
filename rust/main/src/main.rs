#![allow(non_upper_case_globals)]
#![allow(non_camel_case_types)]
#![allow(non_snake_case)]

use std::{
    env,
    ffi::CString,
    os::raw::{c_char, c_int},
};
include!(concat!(env!("OUT_DIR"), "/bindings.rs"));

fn main() {
    println!("Hello, world!, {}", env!("OUT_DIR"));
    let mut running: bool = true;
    let mut count: u32 = 0;
    unsafe {
        SDL_Init(SDL_INIT_VIDEO);
        const width: c_int = 1000;
        const height: c_int = 500;
        let string_title = CString::new("SDL3 Rust").unwrap();
        let title: *const c_char = string_title.as_ptr();
        let window: *mut SDL_Window = SDL_CreateWindow(title, width, height, 0);
        const temp: *const c_char = std::ptr::null();
        let renderer: *mut SDL_Renderer = SDL_CreateRenderer(window, temp);

        while running == true {
            count = count + 1;
        }
    }
    println!("Hello, world!");
}
