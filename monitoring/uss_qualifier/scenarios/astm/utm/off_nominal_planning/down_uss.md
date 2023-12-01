# Off-Nominal planning: down USS test scenario

## Description
This test aims to test the strategic coordination requirements that relate to the down USS mechanism:
- **[astm.f3548.v21.SCD0005](../../../../requirements/astm/f3548/v21.md)**
- **[astm.f3548.v21.SCD0010](../../../../requirements/astm/f3548/v21.md)**

It involves a single tested USS. The USS qualifier acts as a virtual USS that may have its availability set to down.

## Resources
### flight_intents
FlightIntentsResource that provides the following flight intents:

<table>
  <tr>
    <th>Flight intent ID</th>
    <th>Flight name</th>
    <th>Priority</th>
    <th>State</th><!-- TODO: Update with usage_state and uas_state when new flight planning API is adopted -->
    <th>Must conflict with</th>
    <th>Must not conflict with</th>
  </tr>
  <tr>
    <td><code>flight_1_planned_vol_A</code></td>
    <td rowspan="2">Flight 1</td>
    <td rowspan="5">Any</td>
    <td>Accepted</td>
    <td rowspan="2">Flight 2</td>
    <td rowspan="2">Flight 2m</td>
  </tr>
  <tr>
    <td><code>flight_2_planned_vol_A</code></td>
    <td rowspan="2">Flight 2</td>
    <td rowspan="3">Higher than Flight 1*</td>
    <td>Accepted</td>
    <td rowspan="2">Flight 1</td>
    <td rowspan="2">N/A</td>
  </tr>
</table>


### tested_uss
FlightPlannerResource that is under test and will manage flight 1.

### dss
DSSInstanceResource that provides access to a DSS instance where:
- flight creation/sharing can be verified,
- the USS qualifier acting as a virtual USS can create operational intents, and
- the USS qualifier can act as an availability arbitrator.

## Setup test case
### Resolve USS ID of virtual USS test step
Make a dummy request to the DSS in order to resolve the USS ID of the virtual USS.

#### Successful dummy query check

### [Restore virtual USS availability test step](../set_uss_available.md)

### Clear operational intents created by virtual USS test step
Delete any leftover operational intents created at DSS by virtual USS.

#### Successful operational intents cleanup check
If the search for own operational intents or their deletion fail, this check fails per **[astm.f3548.v21.DSS0005](../../../../requirements/astm/f3548/v21.md)**.

## Plan flight in conflict with planned flight managed by down USS test case
This test case aims at testing requirement **[astm.f3548.v21.SCD0005](../../../../requirements/astm/f3548/v21.md)**.

### Virtual USS plans high-priority flight 2 test step
The USS qualifier, acting as a virtual USS, creates an operational intent at the DSS with a high priority and a non-working base URL.
The objective is to make the later request by the tested USS to retrieve operational intent details to fail.

#### Operational intent successfully created check
If the creation of the operational intent reference at the DSS fails, this check fails per **[astm.f3548.v21.DSS0005](../../../../requirements/astm/f3548/v21.md)**.

### [Declare virtual USS as down at DSS test step](../set_uss_down.md)

### Tested USS attempts to plan low-priority flight 1 test step
The low-priority flight 1 of the tested USS conflicts with high-priority flight 2 of the virtual USS.
However, since:
- the virtual USS is declared as down at the DSS,
- it does not respond for operational intent details, and
- the operational intent for flight 2 is in 'Planned' state,
The tested USS should evaluate the operational intent of flight 2 as having the lowest bound priority status, i.e. a priority strictly lower than the lowest priority allowed by the local regulation.

As such, the tested USS may either:
- Successfully plan flight 1 over the higher-priority flight 2, or
- Decide to be more conservative and reject the planning of flight 1.

#### Successful planning check
All flight intent data provided is correct and the USS should have either successfully planned the flight per **[astm.f3548.v21.SCD0005](../../../../requirements/astm/f3548/v21.md)**,
or rejected properly the planning if it decided to be more conservative with such conflicts.
If the USS indicates that the injection attempt failed, this check will fail.

Do take note that if the USS rejects the planning, this check will not fail, but the following *Rejected planning check*
will. Refer to this check for more information.

#### Rejected planning check
All flight intent data provided is correct and the USS should have either successfully planned the flight or rejected
properly the planning if it decided to be more conservative with such conflicts.
If the USS rejects the planning, this check will fail with a low severity per **[astm.f3548.v21.SCD0005](../../../../requirements/astm/f3548/v21.md)**.
This won't actually fail the test but will serve as a warning.

#### Failure check
All flight intent data provided was complete and correct. It should have been processed successfully, allowing the USS
to reject or accept the flight. If the USS indicates that the injection attempt failed, this check will fail per
**[interuss.automated_testing.flight_planning.ExpectedBehavior](../../../../requirements/interuss/automated_testing/flight_planning.md)**.

### [Validate low-priority flight 1 status test step](../validate_shared_operational_intent.md)
This step validates that the response of the USS is consistent with the flight shared, i.e. either it was properly
planned, or the USS rejected the planning.

If the planning was accepted, flight 1 should have been shared.
If the planning was rejected, flight 1 should not have been shared, thus should not exist.

## Cleanup
### Availability of virtual USS restored check
**[astm.f3548.v21.DSS0100](../../../../requirements/astm/f3548/v21.md)**

### Successful flight deletion check
Delete flights injected at USS through the flight planning interface.
**[interuss.automated_testing.flight_planning.DeleteFlightSuccess](../../../../requirements/interuss/automated_testing/flight_planning.md)**

### Successful operational intents cleanup check
Delete operational intents created at DSS by virtual USS.
If the search for own operational intents or their deletion fail, this check fails per **[astm.f3548.v21.DSS0005](../../../../requirements/astm/f3548/v21.md)**.