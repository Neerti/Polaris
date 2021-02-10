import { useBackend } from '../backend';
import { Button, LabeledList, Section, ProgressBar, Fragment } from '../components';
import { Window } from '../layouts';

export const Turret = (props, context) => {
  const { act, data } = useBackend(context);
  const weaponModeArray = data.weaponModes || [];
  return (
    <Window resizable>
      <Window.Content scrollable>
        <Section title="Power System">
          <LabeledList>
            <LabeledList.Item label="Power">
              <Button
                content="On"
                icon="toggle-on"
                selected={data.isOn ? "selected" : null}
                onClick={() => act('turnOn')} />
              <Button
                content="Off"
                icon="toggle-off"
                selected={data.isOn ? null : "selected"}
                onClick={() => act('turnOff')} />
            </LabeledList.Item>
            <LabeledList.Item label="Cell Charge">
              <ProgressBar
                ranges={{
                  bad: [-Infinity, 33],
                  average: [33, 66],
                  good: [66, Infinity],
                }}
                value={data.cellChargePercent}
                minValue={0}
                maxValue={100} />
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section title="Weapon System">
          <LabeledList>
            <LabeledList.Item label="Weapon Installed">
              {data.weaponName}
            </LabeledList.Item>
            <LabeledList.Item label="Firemodes Available">
              {weaponModeArray.map(wm => (
                <Button key={wm}>
                  content={wm.name}
                  onClick={() => act('firemodeSwitchTo', {key})}
                </Button>
              ))}
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
