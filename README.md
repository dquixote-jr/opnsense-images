<div id="top"></div>

<!-- PROJECT SHIELDS -->
[![Contributors][contributors-shield]][contributors-url]
[![Builds][builds-shield]][builds-url]
[![Versions][versions-shield]][versions-url]
[![Starrers][stars-shield]][stars-url]
[![Forks][forks-shield]][forks-url]
[![Issues][issues-shield]][issues-url]
[![License][license-shield]][license-url]


<!-- PROJECT LOGO -->
<br />
<div align="center">
  <a href="[https://gitlab.com/open-images/opnsense](https://gitlab.com/open-images/opnsense)">
    <img src="images/logo.png" alt="Logo" width="150">
  </a>

<h3 align="center">OPNsense image for OpenStack</h3>

  <p align="center">
    Port of OPNsense distribution for OpenStack environments
    <br />
    <a href="[def]"><strong>Explore the docs »</strong></a>
    <br />
    <br />
    <a href="https://gitlab.com/open-images/opnsense/issues">Report Bug</a>
    ·
    <a href="https://gitlab.com/open-images/opnsense/issues">Request Feature</a>
  </p>
</div>

<!-- ABOUT THE PROJECT -->
## About The Project

This project is a port of OPNsense releases for OpenStack environments.  
This image used the GitLab CI/CD pipeline and packer from Hashicorp to build base image and we make some change to make it compatible with OpenStack environments and cloud-init.  

This image is updated when OPNsense team released a new version of the OS [here](https://docs.opnsense.org/releases.html "OPNsense Release Inventory").


<p align="right">(<a href="#top">back to top</a>)</p>

### How to use this image

1. Set your OpenStack environement variables
2. Download the latest image from the [repository page](https://s3.openimages.cloud/opnsense-image/index.html "Images Repository")
3. Upload image to your OpenStack environment

   ```bash
   openstack image create --disk-format=qcow2 --container-format=bare --min-disk 8 --file opnsense-<VERSION>.qcow2  'OPNsense <VERSION>'
   ```

<p align="right">(<a href="#top">back to top</a>)</p>

<!-- CONTRIBUTING -->
## Contributing

Contributions are what make the open source community such an amazing place to learn, inspire, and create. Any contributions you make are **greatly appreciated**.

If you have a suggestion that would make this better, please fork the repo and create a pull request. You can also simply open an issue with the tag "enhancement".
Don't forget to give the project a star! Thanks again!

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

<p align="right">(<a href="#top">back to top</a>)</p>



<!-- LICENSE -->
## License

Distributed under the BSD 2-Clause "Simplified" License. See `LICENSE.txt` for more information.

<p align="right">(<a href="#top">back to top</a>)</p>



<!-- CONTACT -->
## Contact

Kevin Allioli - [@linit_io](https://twitter.com/linit_io) - kevin@linit.io.  
Valentin Chassignol - [@vinetos](https://twitter.com/vinetos) - contact@vinetos.fr.  
Project Link: https://gitlab.com/open-images/opnsense

<p align="right">(<a href="#top">back to top</a>)</p>


<!-- MARKDOWN LINKS & IMAGES -->
<!-- https://www.markdownguide.org/basic-syntax/#reference-style-links -->
[contributors-shield]: https://img.shields.io/gitlab/contributors/open-images/opnsense.svg?style=for-the-badge
[contributors-url]: https://gitlab.com/linitio/openstack-alpine-image/graphs/contributors
[builds-shield]: https://img.shields.io/gitlab/pipeline-status/open-images/opnsense.svg?style=for-the-badge
[builds-url]: https://gitlab.com/open-images/opnsense/-/pipelines
[versions-shield]: https://img.shields.io/gitlab/v/tag/open-images/opnsense?style=for-the-badge&label=Latest%20version
[versions-url]: https://gitlab.com/open-images/opnsense/-/tags?sort=version_desc
[stars-shield]: https://img.shields.io/gitlab/stars/open-images/opnsense.svg?style=for-the-badge
[stars-url]: https://gitlab.com/open-images/opnsense/-/starrers
[forks-shield]: https://img.shields.io/gitlab/forks/open-images/opnsense?style=for-the-badge
[forks-url]: https://gitlab.com/open-images/opnsense/-/forks
[issues-shield]: https://img.shields.io/gitlab/issues/open/open-images/opnsense.svg?style=for-the-badge
[issues-url]: https://gitlab.com/open-images/opnsense/-/issues
[license-shield]: https://img.shields.io/gitlab/license/open-images/opnsense.svg?style=flat-square
[license-url]: https://gitlab.com/open-images/opnsense/-/blob/main/LICENCE.txt