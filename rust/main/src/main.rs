#![allow(non_upper_case_globals)]
#![allow(non_camel_case_types)]
#![allow(non_snake_case)]

use std::{
    env,
    ffi::CString,
    mem::MaybeUninit,
    os::raw::{c_char, c_int, c_uint},
};
include!(concat!(env!("OUT_DIR"), "/bindings.rs"));

const SDL_WINDOW_FULLSCREEN: u64 = 0x0000000000000001;

fn main() {
    println!("Hello, world!, {}", env!("OUT_DIR"));
    let mut running: bool = true;
    let mut count: u32 = 0;
    unsafe {
        if false == SDL_Init(SDL_INIT_VIDEO) {
            println!("Error starting video");
            return;
        }
        const width: c_int = 1000;
        const height: c_int = 500;
        let string_title = CString::new("SDL3 Rust").unwrap();
        let title: *const c_char = string_title.as_ptr();
        let window: *mut SDL_Window = SDL_CreateWindow(title, width, height, 0);
        println!("window: {:?}", &window.as_ref());
        assert!(!window.is_null());
        const temp: *const c_char = std::ptr::null();
        let renderer: *mut SDL_Renderer = SDL_CreateRenderer(window, temp);
        assert!(!renderer.is_null());
        println!("renderer: {:?}", &renderer.as_ref());

        let mut e = MaybeUninit::<SDL_Event>::uninit();
        while running == true {
            count = count + 1;
            SDL_SetRenderDrawColor(renderer, 0, 0, 0, 100);
            SDL_RenderClear(renderer);
            while true == SDL_PollEvent(e.as_mut_ptr()) {
                let event = e.assume_init();
                if event.type_ == 0x100 {
                    running = false;
                }
            }

            SDL_RenderPresent(renderer);
        }
    }
    println!("Hello, world!");
}
