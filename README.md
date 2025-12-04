<a href="https://github.com/camaraproject/SponsoredData/commits/" title="Last Commit"><img src="https://img.shields.io/github/last-commit/camaraproject/SponsoredData?style=plastic"></a>
<a href="https://github.com/camaraproject/SponsoredData/issues" title="Open Issues"><img src="https://img.shields.io/github/issues/camaraproject/SponsoredData?style=plastic"></a>
<a href="https://github.com/camaraproject/SponsoredData/pulls" title="Open Pull Requests"><img src="https://img.shields.io/github/issues-pr/camaraproject/SponsoredData?style=plastic"></a>
<a href="https://github.com/camaraproject/SponsoredData/graphs/contributors" title="Contributors"><img src="https://img.shields.io/github/contributors/camaraproject/SponsoredData?style=plastic"></a>
<a href="https://github.com/camaraproject/SponsoredData" title="Repo Size"><img src="https://img.shields.io/github/repo-size/camaraproject/SponsoredData?style=plastic"></a>
<a href="https://github.com/camaraproject/SponsoredData/blob/main/LICENSE" title="License"><img src="https://img.shields.io/badge/License-Apache%202.0-green.svg?style=plastic"></a>
<a href="https://github.com/camaraproject/SponsoredData/releases/latest" title="Latest Release"><img src="https://img.shields.io/github/release/camaraproject/SponsoredData?style=plastic"></a>
<a href="https://github.com/camaraproject/Governance/blob/main/ProjectStructureAndRoles.md" title="Sandbox API Repository"><img src="https://img.shields.io/badge/Sandbox%20API%20Repository-yellow?style=plastic"></a>

# SponsoredData

Sandbox API Repository to describe, develop, document, and test the **Sponsored Data Service API(s)**. This repository currently belongs to the *Sandbox* stage and is under active development within the CAMARA framework.

* API Repository [wiki page](https://lf-camaraproject.atlassian.net/wiki/x/f4CVDg)

---

## Scope

The **Sponsored Data** API enables a sponsoring company to cover the data usage of end users for a defined period and/or data volume, thereby strengthening its brand presence and enhancing the user experience.

The API is organized into three hierarchical levels:

- **Sponsor:** The company that finances the sponsored data usage.  
- **Campaigns:** Sets of sponsorship actions contracted by sponsors for various commercial or marketing purposes.  
- **Sponsored Subscribers:** Individual users participating in a campaign, who opt in to receive sponsored data for a defined volume and duration. The sponsorship is always activated upon the user’s explicit choice or consent.  

Campaigns can follow one of two commercial models:

Campaigns can be organized under different commercial models, depending on the sponsorship agreement between the Sponsor and the Operator:

- **Prepaid** — The Sponsor pre-purchases a total data volume, from which units are deducted as sponsored sessions are started and consumed.  
- **Postpaid** — The Sponsor is billed at the end of the campaign cycle based on the actual sponsored data consumption.

The API supports the following operations:

- `/start-sponsorship`  
- `/session-status`  
- `/revoke-sponsorship`  
- `/campaign-status`  
- `/active-sponsorships`  
- `/configure-alerts`  
- `/campaign-management`

Identifiers such as **Sponsor_Id**, **Campaign_ID** and **Session_ID** are generated and managed by the Operator Platform (MNO). 

---

## Release Information

The repository has no (pre)releases yet, work in progress is within the main branch.  


---

## Contributing

* Meetings are held virtually <!-- for new, independent Sandbox API repositories request a meeting link from the LF admin team or replace the information with the existing meeting information of the Sub Project -->

  * Schedule: Bi-Weekly on Fridays at 14:00 UTC
  * [Registration / Join](https://zoom-lfx.platform.linuxfoundation.org/meetings/telcoapi) !! Update this link with your meeting registration/join link and delete the task
  * Minutes: Access [meeting minutes](https://github.com/camaraproject/SponsoredData/tree/main/documentation/MeetingMinutes)
* Mailing List
  * Subscribe / Unsubscribe to the mailing list <https://lists.camaraproject.org/g/sp-sponsored-data>.
  * A message to the community of this Sub Project can be sent using <sp-sponsored-data@lists.camaraproject.org>.
