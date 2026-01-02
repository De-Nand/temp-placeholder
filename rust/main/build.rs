use std::{
    env, fs,
    io::{BufWriter, Write},
    path::{self, PathBuf},
};

fn main() {
    println!("Starting the build.rs");

    println!("cargo:rustc-link-arg=-v");
    //let home = env::var("HOME").expect("Home environment variable should be set");
    // Cannot use the ~ to find the location of SDL as it will not be expanded by the linker.
    // Have to format the absolute path to get the location
    //let framework_path = format!("{}/SDL", home);
    let framework_path = "../../sdls/macos/SDL";
    //let framework_path_core = format!("{}/SDL3.framework/SDL3", framework_path);
    //let framework_headers_core = "./SDL3";
    let framework_headers_core = format!("{}/SDL3.framework/Headers", framework_path);
    //let framework_headers_image = format!("{}/SDL3_image.framework/Headers", framework_path);
    //let framework_headers_ttf = format!("{}/SDL3_ttf.framework/Headers", framework_path);
    println!("cargo:rustc-link-search=framework={}", &framework_path);
    println!("cargo:rustc-link-lib=framework=SDL3");

    //create_wrapper_file(&framework_headers_core);

    let out_path = PathBuf::from(env::var("OUT_DIR").expect("Output directory to be available"));
    //    .clang_arg(format!("-rpath {}", &framework_path))

    bindgen::Builder::default()
        .header("sdl_wrapper2.h")
        .clang_arg(format!("-I{}", &framework_headers_core))
        .clang_arg(format!("-F{}", &framework_path))
        .parse_callbacks(Box::new(bindgen::CargoCallbacks::new()))
        .generate()
        .expect("Bindings to be setup")
        .write_to_file(out_path.join("bindings.rs"))
        .expect("could not write bindings");

    println!("cargo:rustc-link-arg=-Wl,-rpath,{}", &framework_path);
}

fn create_wrapper_file(framework_headers_core: &String) {
    let sdl_wrapper = fs::File::create("sdl_wrapper.h").unwrap();
    let mut writer = BufWriter::new(sdl_wrapper);

    for header_file in fs::read_dir(framework_headers_core).expect("SDL headers available") {
        let hf = header_file.unwrap().file_name().into_string().unwrap();
        _ = writeln!(&mut writer, "#include \"{}\"", hf);
    }
    _ = writer.flush();
}
