# set -l device = wlp0s20f3
sudo ip link set wlp0s20f3 down
sudo macchanger -r wlp0s20f3
sudo ip link set wlp0s20f3 up
ip a
