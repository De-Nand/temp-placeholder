fn main() {
    println!("Starting the build.rs");

    let headers = "../../sdls/windows/include";
    let sdl_library = "../../sdls/windows/lib";

    println!("cargo:rustc-link-arg=I{}", headers);
    println!("cargo:rustc-link-arg=L{}", sdl_library);
    println!("cargo:rustc-link-lib=dylib=SDL3");

    //pkg_config::Config::new().probe("SDL3").unwrap();

    //cc::Build::new()
    //    .include("../../../sdls/include")
    //    .compile("main");

}
