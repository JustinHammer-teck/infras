ign_path :=  "/var/lib/incus/ignition/"

default:
	@just --list

convert $NODE_NAME $BU:
	export FLATCAR_NODE={{ NODE_NAME }}; op inject -i {{ BU }}.template | envsubst - > {{ BU }}.trans

translate $BU $DEST:
	podman run --rm -i quay.io/coreos/butane:release < {{ BU }}.trans > {{ ign_path }}{{ DEST }}

set $VM $IGN:
	incus config set {{ VM }} raw.qemu="-fw_cfg name=opt/org.flatcar-linux/config,file={{ ign_path }}{{ IGN }}"

flatcar-translate $NODE_NAME $BU $VM $IGN:
	@just convert {{ NODE_NAME }} {{ BU }}
	@just translate {{ BU }} {{ IGN }}
	@just set {{ VM }} {{ IGN }}
