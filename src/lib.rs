use zed_extension_api as zed;

struct NetLinxExtension;

impl zed::Extension for NetLinxExtension {
    fn new() -> Self {
        NetLinxExtension
    }
}

zed::register_extension!(NetLinxExtension);
