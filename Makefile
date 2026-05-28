INSTALL_TARGET_PROCESSES = Instagram

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = hkoom

hkoom_FILES = Tweak.x
hkoom_CFLAGS = -fobjc-arc -DTHEOS_LEAN_AND_MEAN
hkoom_FRAMEWORKS = UIKit Foundation CoreGraphics
hkoom_PRIVATE_FRAMEWORKS = Preferences

include $(THEOS_MAKE_PATH)/tweak.mk
