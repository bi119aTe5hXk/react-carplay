import { Stream } from '../../../main/Globals'
import Grid from '@mui/material/Unstable_Grid2'
import React, { useState } from 'react'
import { Button, TextField } from '@mui/material'

interface SettingsProps {
  setSettings: (key: any, value: any) => void,
  setOpenStream: React.Dispatch<React.SetStateAction<boolean>>
}

function MostStream({ setSettings, setOpenStream }: SettingsProps) {
  const [stream, setStream] = useState<Stream>({
    fBlockID: -1,
    instanceID: -1,
    sinkNr: -1,
    sourceAddrHigh: -1,
    sourceAddrLow: -1
  })

  const updateStream = (key: keyof Stream, value: string) => {
    setStream((prevState) => ({ ...prevState, [key]: parseInt(value) }))
  }

  const handleSave = () => {
    setSettings('most', {stream: {...stream}})
    setSettings('piMost', true)
    setOpenStream(false)
  }

  return (
    <Grid spacing={2} container sx={{ marginTop: '5%' }}>
      <Grid xs={4}>
        <TextField
          label={'FBLOCK-ID'}
          value={stream.fBlockID}
          onChange={(event: React.ChangeEvent<HTMLInputElement>) => {
            updateStream('fBlockID', event.target.value)
          }}
          error={Number.isNaN(stream.fBlockID)}
          helperText={!Number.isNaN(stream.fBlockID) ? '' : 'Format must be in hex'}
        />
      </Grid>
      <Grid xs={4}>
        <TextField
          label={'INSTANCE-ID'}
          value={stream.instanceID}
          onChange={(event: React.ChangeEvent<HTMLInputElement>) => {
            updateStream('instanceID', event.target.value)
          }}
          error={Number.isNaN(stream.instanceID)}
          helperText={!Number.isNaN(stream.instanceID) ? '' : 'Format must be in hex'}
        />
      </Grid>
      <Grid xs={4}>
        <TextField
          label={'SINK NUMBER'}
          value={stream.sinkNr}
          onChange={(event: React.ChangeEvent<HTMLInputElement>) => {
            updateStream('sinkNr', event.target.value)
          }}
          error={Number.isNaN(stream.sinkNr)}
          helperText={!Number.isNaN(stream.sinkNr) ? '' : 'Format must be in hex'}
        />
      </Grid>
      <Grid xs={6}>
        <TextField
          label={'SOURCE ADDRESS HIGH'}
          value={stream.sourceAddrHigh}
          onChange={(event: React.ChangeEvent<HTMLInputElement>) => {
            updateStream('sourceAddrHigh', event.target.value)
          }}
          error={Number.isNaN(stream.sourceAddrHigh)}
          helperText={!Number.isNaN(stream.sourceAddrHigh) ? '' : 'Format must be in hex'}
        />
      </Grid>
      <Grid xs={6}>
        <TextField
          label={'SOURCE ADDRESS LOW'}
          value={stream.sourceAddrLow}
          onChange={(event: React.ChangeEvent<HTMLInputElement>) => {
            updateStream('sourceAddrLow', event.target.value)
          }}
          error={Number.isNaN(stream.sourceAddrLow)}
          helperText={!Number.isNaN(stream.sourceAddrLow) ? '' : 'Format must be in hex'}
        />
      </Grid>
      <Grid xs={12}>
        <Button
          disabled={
            !(
              stream.fBlockID > -1 &&
              stream.instanceID > -1 &&
              stream.sinkNr > -1 &&
              stream.sourceAddrHigh > -1 &&
              stream.sourceAddrLow > -1
            )
          }
          onClick={() => handleSave()}
        >
          SAVE
        </Button>
      </Grid>
    </Grid>
  )
}

export default MostStream
