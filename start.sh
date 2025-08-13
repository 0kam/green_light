rm -rf /home/okamoto/green_light/public &&
hugo server \
	--appendPort=false \
	--baseURL=https://0kam.net/blog \
	--liveReloadPort=443 \
	--navigateToChanged \
	--port=1313
